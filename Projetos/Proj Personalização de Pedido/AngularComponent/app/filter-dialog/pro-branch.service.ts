import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
    providedIn: 'root'
})
export class ProBranchService {
    constructor(private http: HttpClient) { }

    getUserBranches(name: string, page: number, size: number): Observable<any> {
        return this.http.get<any>(`/api/branches`, {
            params: {
                name,
                page: page.toString(),
                size: size.toString()
            }
        });
    }
}
