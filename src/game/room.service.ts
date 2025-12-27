import { Injectable, Logger } from '@nestjs/common';
import { Room, RoomStatus } from './interfaces/room.interface';
import { Player } from './interfaces/player.interface';
import { Socket } from 'socket.io';
import { RoomInfoDto, PlayerInfoDto } from './dto/game.dto';

@Injectable()
export class RoomService {
  private readonly logger = new Logger(RoomService.name);
  private rooms: Map<string, Room> = new Map();
  private playerRoomMap: Map<string, string> = new Map(); // socketId -> roomCode

  /**
   * Generate a unique room code (6 characters)
   */
  private generateRoomCode(): string {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code: string;
    do {
      code = Array.from(
        { length: 6 },
        () => characters[Math.floor(Math.random() * characters.length)],
      ).join('');
    } while (this.rooms.has(code));
    return code;
  }

  /**
   * Create a new room
   */
  createRoom(
    socket: Socket,
    roomName: string,
    maxPlayers: number,
    username: string,
  ): Room {
    const roomCode = this.generateRoomCode();
    const roomId = `room_${Date.now()}_${roomCode}`;

    const host: Player = {
      id: socket.id,
      socket,
      username,
      isReady: false,
      isHost: true,
    };

    const room: Room = {
      id: roomId,
      code: roomCode,
      name: roomName,
      hostId: socket.id,
      players: new Map([[socket.id, host]]),
      maxPlayers: Math.min(Math.max(maxPlayers, 2), 10), // Clamp between 2-10
      status: RoomStatus.WAITING,
      createdAt: new Date(),
    };

    this.rooms.set(roomCode, room);
    this.playerRoomMap.set(socket.id, roomCode);

    this.logger.log(`Room created: ${roomCode} by ${username}`);
    return room;
  }

  /**
   * Join an existing room
   */
  joinRoom(
    socket: Socket,
    roomCode: string,
    username: string,
  ): { success: boolean; room?: Room; error?: string } {
    const room = this.rooms.get(roomCode.toUpperCase());

    if (!room) {
      return { success: false, error: 'Room not found' };
    }

    if (room.status !== RoomStatus.WAITING) {
      return { success: false, error: 'Game already in progress' };
    }

    if (room.players.size >= room.maxPlayers) {
      return { success: false, error: 'Room is full' };
    }

    // Check if username is already taken in this room
    const usernameTaken = Array.from(room.players.values()).some(
      (p) => p.username.toLowerCase() === username.toLowerCase(),
    );
    if (usernameTaken) {
      return { success: false, error: 'Username already taken in this room' };
    }

    const player: Player = {
      id: socket.id,
      socket,
      username,
      isReady: false,
      isHost: false,
    };

    room.players.set(socket.id, player);
    this.playerRoomMap.set(socket.id, roomCode.toUpperCase());

    this.logger.log(`Player ${username} joined room: ${roomCode}`);
    return { success: true, room };
  }

  /**
   * Leave a room
   */
  leaveRoom(socketId: string): {
    room?: Room;
    wasHost: boolean;
    newHostId?: string;
    roomDeleted: boolean;
  } {
    const roomCode = this.playerRoomMap.get(socketId);
    if (!roomCode) {
      return { wasHost: false, roomDeleted: false };
    }

    const room = this.rooms.get(roomCode);
    if (!room) {
      this.playerRoomMap.delete(socketId);
      return { wasHost: false, roomDeleted: false };
    }

    const player = room.players.get(socketId);
    const wasHost = player?.isHost || false;

    room.players.delete(socketId);
    this.playerRoomMap.delete(socketId);

    // If room is empty, delete it
    if (room.players.size === 0) {
      this.rooms.delete(roomCode);
      this.logger.log(`Room deleted (empty): ${roomCode}`);
      return { room, wasHost, roomDeleted: true };
    }

    // If host left, assign new host
    let newHostId: string | undefined;
    if (wasHost) {
      const firstEntry = room.players.entries().next();
      if (!firstEntry.done) {
        const [firstPlayerId, firstPlayer]: [string, Player] = firstEntry.value;
        firstPlayer.isHost = true;
        room.hostId = firstPlayerId;
        newHostId = firstPlayerId;
        this.logger.log(
          `New host assigned in room ${roomCode}: ${firstPlayer.username}`,
        );
      }
    }

    return { room, wasHost, newHostId, roomDeleted: false };
  }

  /**
   * Set player ready status
   */
  setPlayerReady(
    socketId: string,
    isReady: boolean,
  ): { success: boolean; room?: Room; error?: string } {
    const roomCode = this.playerRoomMap.get(socketId);
    if (!roomCode) {
      return { success: false, error: 'Not in a room' };
    }

    const room = this.rooms.get(roomCode);
    if (!room) {
      return { success: false, error: 'Room not found' };
    }

    const player = room.players.get(socketId);
    if (!player) {
      return { success: false, error: 'Player not found' };
    }

    player.isReady = isReady;
    this.logger.log(`Player ready in the room ${roomCode}`);
    return { success: true, room };
  }

  /**
   * Start the game (only host can start)
   */
  startGame(socketId: string): {
    success: boolean;
    room?: Room;
    error?: string;
  } {
    const roomCode = this.playerRoomMap.get(socketId);
    if (!roomCode) {
      return { success: false, error: 'Not in a room' };
    }

    const room = this.rooms.get(roomCode);
    if (!room) {
      return { success: false, error: 'Room not found' };
    }

    if (room.hostId !== socketId) {
      return { success: false, error: 'Only the host can start the game' };
    }

    if (room.status !== RoomStatus.WAITING) {
      return { success: false, error: 'Game already started' };
    }

    // Check if all players are ready (except host)
    const allReady = Array.from(room.players.values())
      .filter((p) => !p.isHost)
      .every((p) => p.isReady);

    if (!allReady && room.players.size > 1) {
      return { success: false, error: 'Not all players are ready' };
    }

    if (room.players.size < 2) {
      return { success: false, error: 'Need at least 2 players to start' };
    }

    room.status = RoomStatus.PLAYING;
    this.logger.log(`Game started in room: ${roomCode}`);
    return { success: true, room };
  }

  /**
   * End the game
   */
  endGame(roomCode: string): { success: boolean; room?: Room; error?: string } {
    const room = this.rooms.get(roomCode);
    if (!room) {
      return { success: false, error: 'Room not found' };
    }

    room.status = RoomStatus.FINISHED;
    return { success: true, room };
  }

  /**
   * Reset room for a new game
   */
  resetRoom(socketId: string): {
    success: boolean;
    room?: Room;
    error?: string;
  } {
    const roomCode = this.playerRoomMap.get(socketId);
    if (!roomCode) {
      return { success: false, error: 'Not in a room' };
    }

    const room = this.rooms.get(roomCode);
    if (!room) {
      return { success: false, error: 'Room not found' };
    }

    if (room.hostId !== socketId) {
      return { success: false, error: 'Only the host can reset the game' };
    }

    room.status = RoomStatus.WAITING;
    room.gameState = undefined;
    room.players.forEach((player) => {
      if (!player.isHost) {
        player.isReady = false;
      }
    });

    this.logger.log(`Room reset: ${roomCode}`);
    return { success: true, room };
  }

  /**
   * Get room by code
   */
  getRoom(roomCode: string): Room | undefined {
    return this.rooms.get(roomCode.toUpperCase());
  }

  /**
   * Get room by socket id
   */
  getRoomBySocketId(socketId: string): Room | undefined {
    const roomCode = this.playerRoomMap.get(socketId);
    return roomCode ? this.rooms.get(roomCode) : undefined;
  }

  /**
   * Get player's current room code
   */
  getPlayerRoomCode(socketId: string): string | undefined {
    return this.playerRoomMap.get(socketId);
  }

  /**
   * Convert Room to RoomInfoDto (for sending to clients)
   */
  toRoomInfoDto(room: Room): RoomInfoDto {
    const players: PlayerInfoDto[] = Array.from(room.players.values()).map(
      (player) => ({
        id: player.id,
        username: player.username,
        isReady: player.isReady,
        isHost: player.isHost,
      }),
    );

    return {
      id: room.id,
      code: room.code,
      name: room.name,
      hostId: room.hostId,
      players,
      maxPlayers: room.maxPlayers,
      status: room.status,
    };
  }

  /**
   * Update game state
   */
  updateGameState(roomCode: string, gameState: unknown): boolean {
    const room = this.rooms.get(roomCode);
    if (!room) {
      return false;
    }
    room.gameState = gameState;
    return true;
  }

  /**
   * Get all active rooms (for debugging/admin)
   */
  getAllRooms(): RoomInfoDto[] {
    return Array.from(this.rooms.values()).map((room) =>
      this.toRoomInfoDto(room),
    );
  }
}
