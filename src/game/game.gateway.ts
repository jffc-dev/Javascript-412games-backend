import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { RoomService } from './room.service';
import {
  CreateRoomDto,
  JoinRoomDto,
  PlayerReadyDto,
  GameActionDto,
  ChatMessageDto,
} from './dto/game.dto';
import { RoomStatus } from './interfaces/room.interface';

@WebSocketGateway({
  cors: {
    origin: '*', // Configure this properly for production
  },
  namespace: '/game',
})
export class GameGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(GameGateway.name);

  constructor(private readonly roomService: RoomService) {}

  afterInit() {
    this.logger.log('Game WebSocket Gateway initialized');
  }

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
    client.emit('connected', {
      message: 'Connected to game server',
      id: client.id,
    });
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
    this.handlePlayerLeave(client);
  }

  /**
   * Create a new room
   */
  @SubscribeMessage('createRoom')
  handleCreateRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: CreateRoomDto,
  ) {
    try {
      // Check if player is already in a room
      const existingRoom = this.roomService.getRoomBySocketId(client.id);
      if (existingRoom) {
        return {
          success: false,
          error: 'You are already in a room. Leave first.',
        };
      }

      const room = this.roomService.createRoom(
        client,
        data.roomName,
        data.maxPlayers,
        data.username,
      );

      // Join the socket.io room
      void client.join(room.code);

      const roomInfo = this.roomService.toRoomInfoDto(room);

      this.logger.log(`Room created: ${room.code}`);

      return {
        success: true,
        room: roomInfo,
      };
    } catch (error) {
      this.logger.error('Error creating room:', error);
      return {
        success: false,
        error: 'Failed to create room',
      };
    }
  }

  /**
   * Join an existing room
   */
  @SubscribeMessage('joinRoom')
  handleJoinRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: JoinRoomDto,
  ) {
    try {
      // Check if player is already in a room
      const existingRoom = this.roomService.getRoomBySocketId(client.id);
      if (existingRoom) {
        return {
          success: false,
          error: 'You are already in a room. Leave first.',
        };
      }

      const result = this.roomService.joinRoom(
        client,
        data.roomCode,
        data.username,
      );

      if (!result.success) {
        return result;
      }

      const room = result.room!;
      const roomInfo = this.roomService.toRoomInfoDto(room);

      // Join the socket.io room
      void client.join(room.code);

      // Notify other players in the room
      this.logger.log(
        `Emitting playerJoined to room ${room.code} for player ${data.username}`,
      );
      client.to(room.code).emit('playerJoined', {
        player: {
          id: client.id,
          username: data.username,
          isReady: false,
          isHost: false,
        },
        room: roomInfo,
      });

      return {
        success: true,
        room: roomInfo,
      };
    } catch (error) {
      this.logger.error('Error joining room:', error);
      return {
        success: false,
        error: 'Failed to join room',
      };
    }
  }

  /**
   * Leave the current room
   */
  @SubscribeMessage('leaveRoom')
  handleLeaveRoom(@ConnectedSocket() client: Socket) {
    return this.handlePlayerLeave(client);
  }

  private handlePlayerLeave(client: Socket) {
    try {
      const roomCode = this.roomService.getPlayerRoomCode(client.id);
      if (!roomCode) {
        return { success: true };
      }

      const result = this.roomService.leaveRoom(client.id);

      // Leave the socket.io room
      void client.leave(roomCode);

      if (result.roomDeleted) {
        this.logger.log(`Room ${roomCode} deleted (empty)`);
        return { success: true, roomDeleted: true };
      }

      if (result.room) {
        const roomInfo = this.roomService.toRoomInfoDto(result.room);

        // Notify remaining players
        this.server.to(roomCode).emit('playerLeft', {
          playerId: client.id,
          room: roomInfo,
          newHostId: result.newHostId,
        });
      }

      return { success: true };
    } catch (error) {
      this.logger.error('Error leaving room:', error);
      return { success: false, error: 'Failed to leave room' };
    }
  }

  /**
   * Set player ready status
   */
  @SubscribeMessage('playerReady')
  handlePlayerReady(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: PlayerReadyDto,
  ) {
    try {
      const result = this.roomService.setPlayerReady(client.id, data.isReady);

      if (!result.success) {
        return result;
      }

      const roomInfo = this.roomService.toRoomInfoDto(result.room!);

      // Notify all players in the room
      this.server.to(result.room!.code).emit('playerReadyChanged', {
        playerId: client.id,
        isReady: data.isReady,
        room: roomInfo,
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error setting player ready:', error);
      return { success: false, error: 'Failed to update ready status' };
    }
  }

  /**
   * Start the game (host only)
   */
  @SubscribeMessage('startGame')
  handleStartGame(@ConnectedSocket() client: Socket) {
    try {
      const result = this.roomService.startGame(client.id);

      if (!result.success) {
        return result;
      }

      const room = result.room!;
      const roomInfo = this.roomService.toRoomInfoDto(room);

      // Notify all players that the game has started
      this.server.to(room.code).emit('gameStarted', {
        room: roomInfo,
      });

      this.logger.log(`Game started in room: ${room.code}`);
      return { success: true };
    } catch (error) {
      this.logger.error('Error starting game:', error);
      return { success: false, error: 'Failed to start game' };
    }
  }

  /**
   * Handle game actions (extend this for your specific game logic)
   */
  @SubscribeMessage('gameAction')
  handleGameAction(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: GameActionDto,
  ) {
    try {
      const room = this.roomService.getRoomBySocketId(client.id);

      if (!room) {
        return { success: false, error: 'Not in a room' };
      }

      if (room.status !== RoomStatus.PLAYING) {
        return { success: false, error: 'Game is not in progress' };
      }

      // Broadcast the game action to all players in the room
      const gameActionEvent: {
        playerId: string;
        action: string;
        payload: unknown;
        timestamp: number;
      } = {
        playerId: client.id,
        action: data.action,
        payload: data.payload,
        timestamp: Date.now(),
      };
      this.server.to(room.code).emit('gameActionReceived', gameActionEvent);

      return { success: true };
    } catch (error) {
      this.logger.error('Error handling game action:', error);
      return { success: false, error: 'Failed to process game action' };
    }
  }

  /**
   * Update game state (typically from host)
   */
  @SubscribeMessage('updateGameState')
  handleUpdateGameState(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { gameState: unknown },
  ) {
    try {
      const room = this.roomService.getRoomBySocketId(client.id);

      if (!room) {
        return { success: false, error: 'Not in a room' };
      }

      if (room.hostId !== client.id) {
        return { success: false, error: 'Only host can update game state' };
      }

      this.roomService.updateGameState(room.code, data.gameState);

      // Broadcast the updated game state to all players
      this.server.to(room.code).emit('gameStateUpdated', {
        gameState: data.gameState,
        timestamp: Date.now(),
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error updating game state:', error);
      return { success: false, error: 'Failed to update game state' };
    }
  }

  /**
   * End the game
   */
  @SubscribeMessage('endGame')
  handleEndGame(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { winner?: string; results?: unknown },
  ) {
    try {
      const room = this.roomService.getRoomBySocketId(client.id);

      if (!room) {
        return { success: false, error: 'Not in a room' };
      }

      if (room.hostId !== client.id) {
        return { success: false, error: 'Only host can end the game' };
      }

      const result = this.roomService.endGame(room.code);

      if (!result.success) {
        return result;
      }

      const roomInfo = this.roomService.toRoomInfoDto(result.room!);

      // Notify all players that the game has ended
      this.server.to(room.code).emit('gameEnded', {
        room: roomInfo,
        winner: data.winner,
        results: data.results,
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error ending game:', error);
      return { success: false, error: 'Failed to end game' };
    }
  }

  /**
   * Reset room for a new game
   */
  @SubscribeMessage('resetRoom')
  handleResetRoom(@ConnectedSocket() client: Socket) {
    try {
      const result = this.roomService.resetRoom(client.id);

      if (!result.success) {
        return result;
      }

      const roomInfo = this.roomService.toRoomInfoDto(result.room!);

      // Notify all players that the room has been reset
      this.server.to(result.room!.code).emit('roomReset', {
        room: roomInfo,
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error resetting room:', error);
      return { success: false, error: 'Failed to reset room' };
    }
  }

  /**
   * Send a chat message in the room
   */
  @SubscribeMessage('chatMessage')
  handleChatMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ChatMessageDto,
  ) {
    try {
      const room = this.roomService.getRoomBySocketId(client.id);

      if (!room) {
        return { success: false, error: 'Not in a room' };
      }

      const player = room.players.get(client.id);
      if (!player) {
        return { success: false, error: 'Player not found' };
      }

      // Broadcast the chat message to all players in the room
      this.server.to(room.code).emit('chatMessageReceived', {
        playerId: client.id,
        username: player.username,
        message: data.message,
        timestamp: Date.now(),
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error sending chat message:', error);
      return { success: false, error: 'Failed to send message' };
    }
  }

  /**
   * Get current room info
   */
  @SubscribeMessage('getRoomInfo')
  handleGetRoomInfo(@ConnectedSocket() client: Socket) {
    try {
      const room = this.roomService.getRoomBySocketId(client.id);

      if (!room) {
        return { success: false, error: 'Not in a room' };
      }

      return {
        success: true,
        room: this.roomService.toRoomInfoDto(room),
      };
    } catch (error) {
      this.logger.error('Error getting room info:', error);
      return { success: false, error: 'Failed to get room info' };
    }
  }

  /**
   * Kick a player (host only)
   */
  @SubscribeMessage('kickPlayer')
  handleKickPlayer(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { playerId: string },
  ) {
    try {
      const room = this.roomService.getRoomBySocketId(client.id);

      if (!room) {
        return { success: false, error: 'Not in a room' };
      }

      if (room.hostId !== client.id) {
        return { success: false, error: 'Only host can kick players' };
      }

      if (data.playerId === client.id) {
        return { success: false, error: 'Cannot kick yourself' };
      }

      const playerToKick = room.players.get(data.playerId);
      if (!playerToKick) {
        return { success: false, error: 'Player not found' };
      }

      // Notify the kicked player
      playerToKick.socket.emit('kicked', {
        message: 'You have been kicked from the room',
      });

      // Remove the player
      this.roomService.leaveRoom(data.playerId);
      void playerToKick.socket.leave(room.code);

      const roomInfo = this.roomService.toRoomInfoDto(room);

      // Notify remaining players
      this.server.to(room.code).emit('playerKicked', {
        playerId: data.playerId,
        room: roomInfo,
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error kicking player:', error);
      return { success: false, error: 'Failed to kick player' };
    }
  }
}
