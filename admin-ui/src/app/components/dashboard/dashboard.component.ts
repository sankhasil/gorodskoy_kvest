// ─────────────────────────────────────────────────────────
// src/app/components/dashboard/dashboard.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialogModule, MatDialog } from '@angular/material/dialog';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatSnackBar } from '@angular/material/snack-bar';
import { PuzzleService } from '../../services/services';
import { AuthService } from '../../services/services';
import { Puzzle } from '../../models/models';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, MatTableModule, MatButtonModule, MatIconModule, MatChipsModule, MatToolbarModule, MatDialogModule],
  template: `
    <mat-toolbar color="primary" style="background:#1a0a00">
      <span>🗺️ Treasure Hunt Admin</span>
      <span style="flex:1"></span>
      <button mat-icon-button (click)="auth.logout()" title="Logout">
        <mat-icon>logout</mat-icon>
      </button>
    </mat-toolbar>

    <div class="container">
      <div class="header-row">
        <h2>Puzzles ({{ puzzles.length }})</h2>
        <button mat-raised-button color="accent" routerLink="/puzzles/new">
          <mat-icon>add</mat-icon> New Puzzle
        </button>
      </div>

      <table mat-table [dataSource]="puzzles" class="mat-elevation-z2 full-width">
        <ng-container matColumnDef="title">
          <th mat-header-cell *matHeaderCellDef>Title</th>
          <td mat-cell *matCellDef="let p">{{ p.title }}</td>
        </ng-container>
        <ng-container matColumnDef="difficulty">
          <th mat-header-cell *matHeaderCellDef>Difficulty</th>
          <td mat-cell *matCellDef="let p">
            <mat-chip [style.background]="difficultyColor(p.difficulty)">{{ p.difficulty }}</mat-chip>
          </td>
        </ng-container>
        <ng-container matColumnDef="duration">
          <th mat-header-cell *matHeaderCellDef>Est. Time</th>
          <td mat-cell *matCellDef="let p">{{ p.estimatedMinutes }} min</td>
        </ng-container>
        <ng-container matColumnDef="actions">
          <th mat-header-cell *matHeaderCellDef>Actions</th>
          <td mat-cell *matCellDef="let p">
            <button mat-icon-button color="primary" [routerLink]="['/puzzles', p.id, 'clues']" title="Edit Clues">
              <mat-icon>list</mat-icon>
            </button>
            <button mat-icon-button color="accent" [routerLink]="['/puzzles', p.id, 'edit']" title="Edit Puzzle">
              <mat-icon>edit</mat-icon>
            </button>
            <button mat-icon-button color="warn" (click)="deletePuzzle(p)" title="Delete">
              <mat-icon>delete</mat-icon>
            </button>
          </td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr>
        <tr mat-row *matRowDef="let row; columns: columns;"></tr>
      </table>
    </div>
  `,
  styles: [`
    .container { padding:24px; background:#0d0d14; min-height:calc(100vh - 64px); }
    .header-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; }
    .full-width { width:100%; }
    table { background:#1a1a2e; }
    h2 { color:#D4A017; }
  `]
})
export class DashboardComponent implements OnInit {
  puzzles: Puzzle[] = [];
  columns = ['title', 'difficulty', 'duration', 'actions'];

  constructor(public auth: AuthService, private puzzleService: PuzzleService, private snack: MatSnackBar) {}

  ngOnInit() { this.loadPuzzles(); }

  loadPuzzles() {
    this.puzzleService.getAllPuzzles().subscribe(p => this.puzzles = p);
  }

  deletePuzzle(puzzle: Puzzle) {
    if (!confirm(`Delete "${puzzle.title}"?`)) return;
    this.puzzleService.deletePuzzle(puzzle.id).subscribe(() => {
      this.snack.open('Puzzle deleted', 'OK', { duration: 3000 });
      this.loadPuzzles();
    });
  }

  difficultyColor(d: string): string {
    return { EASY: '#2e7d32', MEDIUM: '#e65100', HARD: '#b71c1c', EXPERT: '#4a148c' }[d] ?? '#333';
  }
}
