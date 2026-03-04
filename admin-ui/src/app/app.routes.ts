// src/app/app.routes.ts
import { Routes } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from './services/services';
import { Router } from '@angular/router';

const authGuard = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (auth.isLoggedIn) return true;
  return router.parseUrl('/login');
};

const adminGuard = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (auth.isAdmin) return true;
  return router.parseUrl('/login');
};

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  {
    path: 'login',
    loadComponent: () => import('./components/components').then(m => m.LoginComponent)
  },
  {
    path: 'dashboard',
    canActivate: [adminGuard],
    loadComponent: () => import('./components/components').then(m => m.DashboardComponent)
  },
  {
    path: 'puzzles/new',
    canActivate: [adminGuard],
    loadComponent: () => import('./components/puzzle-form.component').then(m => m.PuzzleFormComponent)
  },
  {
    path: 'puzzles/:id/edit',
    canActivate: [adminGuard],
    loadComponent: () => import('./components/puzzle-form.component').then(m => m.PuzzleFormComponent)
  },
  {
    path: 'puzzles/:id/clues',
    canActivate: [adminGuard],
    loadComponent: () => import('./components/components').then(m => m.ClueEditorComponent)
  },
  { path: '**', redirectTo: '/dashboard' }
];



