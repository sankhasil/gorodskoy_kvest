// src/app/components/login/login.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { AuthService } from '../../services/services';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, MatCardModule, MatFormFieldModule, MatInputModule, MatButtonModule],
  template: `
    <div class="login-wrapper">
      <mat-card class="login-card">
        <mat-card-header>
          <mat-card-title>🗺️ Treasure Hunt Admin</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <mat-form-field appearance="outline" class="full-width">
            <mat-label>Email</mat-label>
            <input matInput [(ngModel)]="email" type="email" />
          </mat-form-field>
          <mat-form-field appearance="outline" class="full-width">
            <mat-label>Password</mat-label>
            <input matInput [(ngModel)]="password" type="password" (keyup.enter)="login()" />
          </mat-form-field>
          <p class="error" *ngIf="error">{{ error }}</p>
        </mat-card-content>
        <mat-card-actions>
          <button mat-raised-button color="primary" class="full-width" (click)="login()" [disabled]="loading">
            {{ loading ? 'Signing in...' : 'Sign In' }}
          </button>
        </mat-card-actions>
      </mat-card>
    </div>
  `,
  styles: [`
    .login-wrapper { display:flex; justify-content:center; align-items:center; min-height:100vh; background:#0d0d1a; }
    .login-card { width:400px; padding:24px; background:#1a1a2e; }
    .full-width { width:100%; margin-bottom:12px; }
    .error { color:red; font-size:13px; }
    mat-card-title { color:#D4A017; font-size:22px; }
  `]
})
export class LoginComponent {
  email = ''; password = ''; error = ''; loading = false;

  constructor(private auth: AuthService, private router: Router) {}

  login() {
    this.loading = true;
    this.auth.login(this.email, this.password).subscribe({
      next: () => this.router.navigate(['/dashboard']),
      error: () => { this.error = 'Invalid credentials'; this.loading = false; }
    });
  }
}

