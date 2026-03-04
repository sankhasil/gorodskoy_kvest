
// ─────────────────────────────────────────────────────────
// src/app/components/clues/clue-editor.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatSnackBar } from '@angular/material/snack-bar';
import { PuzzleService } from '../../services/services';
import { Clue, ClueRequest } from '../../models/models';

@Component({
  selector: 'app-clue-editor',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, MatTableModule, MatButtonModule, MatIconModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatExpansionModule],
  template: `
    <div class="container">
      <div class="header-row">
        <button mat-icon-button routerLink="/dashboard"><mat-icon>arrow_back</mat-icon></button>
        <h2>Clue Editor ({{ clues.length }} clues)</h2>
      </div>

      <!-- Add new clue form -->
      <mat-expansion-panel style="background:#1a1a2e; margin-bottom:24px">
        <mat-expansion-panel-header>
          <mat-panel-title>➕ Add New Clue</mat-panel-title>
        </mat-expansion-panel-header>
        <div class="form-grid">
          <mat-form-field appearance="outline">
            <mat-label>Clue Type</mat-label>
            <mat-select [(ngModel)]="newClue.type">
              <mat-option *ngFor="let t of clueTypes" [value]="t">{{ t }}</mat-option>
            </mat-select>
          </mat-form-field>
          <mat-form-field appearance="outline" class="span-2">
            <mat-label>Clue Content</mat-label>
            <textarea matInput [(ngModel)]="newClue.content" rows="3"></textarea>
          </mat-form-field>
          <mat-form-field appearance="outline">
            <mat-label>Expected Answer</mat-label>
            <input matInput [(ngModel)]="newClue.answer" />
          </mat-form-field>
          <mat-form-field appearance="outline">
            <mat-label>Hint (optional)</mat-label>
            <input matInput [(ngModel)]="newClue.hint" />
          </mat-form-field>
          <button mat-raised-button color="primary" (click)="saveClue()">Save Clue</button>
        </div>
      </mat-expansion-panel>

      <!-- Clues list -->
      <div *ngFor="let clue of clues; let i = index" class="clue-card">
        <div class="clue-header">
          <span class="clue-num">#{{ i + 1 }}</span>
          <span class="clue-type">{{ clue.type }}</span>
          <span style="flex:1"></span>
          <button mat-icon-button color="warn" (click)="deleteClue(clue)"><mat-icon>delete</mat-icon></button>
        </div>
        <p class="clue-content">{{ clue.content }}</p>
        <small class="clue-answer">✓ Answer: {{ clue.answer }}</small>
        <small *ngIf="clue.hint" class="clue-hint"> · 💡 Hint: {{ clue.hint }}</small>
      </div>
    </div>
  `,
  styles: [`
    .container { padding:24px; background:#0d0d14; min-height:100vh; }
    .header-row { display:flex; align-items:center; gap:12px; margin-bottom:20px; }
    h2 { color:#D4A017; margin:0; }
    .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; padding:16px 0; }
    .span-2 { grid-column:span 2; }
    .clue-card { background:#1a1a2e; border-radius:8px; padding:16px; margin-bottom:12px; }
    .clue-header { display:flex; align-items:center; gap:8px; margin-bottom:8px; }
    .clue-num { background:#D4A017; color:#000; border-radius:50%; width:28px; height:28px; display:flex; align-items:center; justify-content:center; font-weight:bold; font-size:12px; }
    .clue-type { background:#333; padding:2px 8px; border-radius:4px; font-size:11px; color:#aaa; }
    .clue-content { color:#eee; margin:0 0 6px; }
    .clue-answer { color:#4caf50; font-size:12px; }
    .clue-hint { color:#ff9800; font-size:12px; }
  `]
})
export class ClueEditorComponent implements OnInit {
  clues: Clue[] = [];
  puzzleId = '';
  clueTypes = ['TEXT', 'RIDDLE', 'IMAGE', 'GPS', 'QR_CODE', 'AUDIO'];
  newClue: Partial<ClueRequest> = { type: 'TEXT', content: '', answer: '', hint: '' };

  constructor(private route: ActivatedRoute, private puzzleService: PuzzleService, private snack: MatSnackBar) {}

  ngOnInit() {
    this.puzzleId = this.route.snapshot.params['id'];
    this.loadClues();
  }

  loadClues() {
    this.puzzleService.getClues(this.puzzleId).subscribe(c => this.clues = c);
  }

  saveClue() {
    const req: ClueRequest = {
      orderIndex: this.clues.length,
      type: this.newClue.type!, content: this.newClue.content!,
      answer: this.newClue.answer!, hint: this.newClue.hint || undefined,
    };
    this.puzzleService.addClue(this.puzzleId, req).subscribe(() => {
      this.snack.open('Clue added!', 'OK', { duration: 2000 });
      this.newClue = { type: 'TEXT', content: '', answer: '', hint: '' };
      this.loadClues();
    });
  }

  deleteClue(clue: Clue) {
    this.puzzleService.deleteClue(clue.id).subscribe(() => this.loadClues());
  }
}