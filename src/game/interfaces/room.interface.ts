import { Player } from './player.interface';

export enum RoomStatus {
  WAITING = 'waiting',
  PLAYING = 'playing',
  FINISHED = 'finished',
}

export interface Room {
  id: string;
  code: string;
  name: string;
  hostId: string;
  players: Map<string, Player>;
  maxPlayers: number;
  status: RoomStatus;
  createdAt: Date;
  gameState?: unknown; // Generic game state - extend based on your game
}
