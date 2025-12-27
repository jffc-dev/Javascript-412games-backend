import { Socket } from 'socket.io';

export interface Player {
  id: string;
  socket: Socket;
  username: string;
  isReady: boolean;
  isHost: boolean;
}
