export class CreateRoomDto {
  roomName: string;
  maxPlayers: number;
  username: string;
}

export class JoinRoomDto {
  roomCode: string;
  username: string;
}

export class PlayerReadyDto {
  roomCode: string;
  isReady: boolean;
}

export class GameActionDto {
  roomCode: string;
  action: string;
  payload?: unknown;
}

export class ChatMessageDto {
  roomCode: string;
  message: string;
}

// Response DTOs
export class RoomInfoDto {
  id: string;
  code: string;
  name: string;
  hostId: string;
  players: PlayerInfoDto[];
  maxPlayers: number;
  status: string;
}

export class PlayerInfoDto {
  id: string;
  username: string;
  isReady: boolean;
  isHost: boolean;
}
