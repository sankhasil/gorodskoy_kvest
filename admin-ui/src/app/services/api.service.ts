// ─────────────────────────────────────────────────────────
// src/app/services/api.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

const BASE_URL = 'http://localhost:8080/api';

@Injectable({ providedIn: 'root' })
export class ApiService {
  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({ Authorization: `Bearer ${token}` });
  }

  get<T>(path: string): Observable<T> {
    return this.http.get<T>(`${BASE_URL}${path}`, { headers: this.headers() });
  }

  post<T>(path: string, body: any): Observable<T> {
    return this.http.post<T>(`${BASE_URL}${path}`, body, { headers: this.headers() });
  }

  put<T>(path: string, body: any): Observable<T> {
    return this.http.put<T>(`${BASE_URL}${path}`, body, { headers: this.headers() });
  }

  delete<T>(path: string): Observable<T> {
    return this.http.delete<T>(`${BASE_URL}${path}`, { headers: this.headers() });
  }
}
