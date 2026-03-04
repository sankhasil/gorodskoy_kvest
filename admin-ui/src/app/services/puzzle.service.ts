// ─────────────────────────────────────────────────────────
// src/app/services/puzzle.service.ts
import { Injectable } from '@angular/core';
import { ApiService } from './api.service';
import { Puzzle, PuzzleRequest, Clue, ClueRequest } from '../models/models';

@Injectable({ providedIn: 'root' })
export class PuzzleService {
  constructor(private api: ApiService) {}

  getAllPuzzles() { return this.api.get<Puzzle[]>('/admin/puzzles'); }
  getPuzzle(id: string) { return this.api.get<Puzzle>(`/puzzles/${id}`); }
  createPuzzle(req: PuzzleRequest) { return this.api.post<Puzzle>('/admin/puzzles', req); }
  updatePuzzle(id: string, req: PuzzleRequest) { return this.api.put<Puzzle>(`/admin/puzzles/${id}`, req); }
  deletePuzzle(id: string) { return this.api.delete<void>(`/admin/puzzles/${id}`); }

  getClues(puzzleId: string) { return this.api.get<Clue[]>(`/admin/puzzles/${puzzleId}/clues`); }
  addClue(puzzleId: string, req: ClueRequest) { return this.api.post<Clue>(`/admin/puzzles/${puzzleId}/clues`, req); }
  updateClue(clueId: string, req: ClueRequest) { return this.api.put<Clue>(`/admin/clues/${clueId}`, req); }
  deleteClue(clueId: string) { return this.api.delete<void>(`/admin/clues/${clueId}`); }
}