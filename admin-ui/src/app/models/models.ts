// src/app/models/models.ts
export interface User {
  userId: string;
  email: string;
  role: 'ADMIN' | 'PLAYER';
  displayName: string;
  token: string;
}

export interface Puzzle {
  id: string;
  title: string;
  description: string;
  difficulty: 'EASY' | 'MEDIUM' | 'HARD' | 'EXPERT';
  active: boolean;
  tags: string[];
  estimatedMinutes: number;
  coverImageUrl?: string;
  createdAt: string;
}

export interface Clue {
  id: string;
  puzzleId: string;
  orderIndex: number;
  type: 'TEXT' | 'IMAGE' | 'GPS' | 'QR_CODE' | 'RIDDLE' | 'AUDIO';
  content: string;
  hint?: string;
  answer: string;
  mediaUrl?: string;
}

export interface PuzzleRequest {
  title: string;
  description: string;
  difficulty: string;
  tags: string[];
  estimatedMinutes: number;
  coverImageUrl?: string;
}

export interface ClueRequest {
  orderIndex: number;
  type: string;
  content: string;
  hint?: string;
  answer: string;
  mediaUrl?: string;
}




