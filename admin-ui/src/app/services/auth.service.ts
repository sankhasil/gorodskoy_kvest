// ─────────────────────────────────────────────────────────
// src/app/services/auth.service.ts
import { Injectable, signal } from '@angular/core';
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs/operators';
import { User } from '../models/models';

const BASE_URL = 'http://localhost:8080/api';

@Injectable({ providedIn: 'root' })
export class AuthService {
  currentUser = signal<User | null>(null);

  constructor(private http: HttpClient, private router: Router) {
    const stored = localStorage.getItem('user');
    if (stored) this.currentUser.set(JSON.parse(stored));
  }

  login(email: string, password: string) {
    return this.http.post<User>(`${BASE_URL}/auth/login`, { email, password }).pipe(
      tap(user => {
        localStorage.setItem('token', user.token);
        localStorage.setItem('user', JSON.stringify(user));
        this.currentUser.set(user);
      })
    );
  }

  logout() {
    localStorage.clear();
    this.currentUser.set(null);
    this.router.navigate(['/login']);
  }

  get isAdmin(): boolean { return this.currentUser()?.role === 'ADMIN'; }
  get isLoggedIn(): boolean { return !!this.currentUser(); }
}