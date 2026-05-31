import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { REST_URLS } from '../shared/resturl';

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, FormsModule, SharedModule],
  template: `
    <div class="row">
      <div class="col-sm-12">
        <app-card cardTitle="User Master">
          <h5>Configure System Users</h5>
          <p>Assign roles to your staff and manage their login access.</p>
          <hr/>
          
          <div class="row mb-4">
            <div class="col-md-4">
              <label class="form-label">Username</label>
              <input type="text" class="form-control" [(ngModel)]="editUser.username" placeholder="Enter username">
            </div>
            <div class="col-md-4">
              <label class="form-label">Full Name</label>
              <input type="text" class="form-control" [(ngModel)]="editUser.fullName" placeholder="Enter full name">
            </div>
            <div class="col-md-4">
              <label class="form-label">Password</label>
              <input type="password" class="form-control" [(ngModel)]="editUser.password" placeholder="Set password">
            </div>
          </div>
          <div class="row mb-4">
            <div class="col-md-4">
              <label class="form-label">Assigned Role</label>
              <select class="form-select" [(ngModel)]="editUser.roleId">
                <option [value]="null" disabled selected>Select Role</option>
                <option *ngFor="let role of roles" [value]="role.id">{{ role.roleName }}</option>
              </select>
            </div>
            <div class="col-md-4 d-flex align-items-end">
              <div class="form-check form-switch mb-2">
                <input class="form-check-input" type="checkbox" id="userActive" [(ngModel)]="editUser.active">
                <label class="form-check-label" for="userActive">Active Account</label>
              </div>
            </div>
            <div class="col-md-4 d-flex align-items-end gap-2">
              <button class="btn btn-primary w-100" (click)="saveUser()">{{ editUser.id ? 'Save Changes' : 'Create User' }}</button>
              <button class="btn btn-link" (click)="resetForm()" *ngIf="editUser.id">Cancel</button>
            </div>
          </div>
          
          <hr/>
          
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr>
                <th>Username</th>
                <th>Full Name</th>
                <th>Role</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let user of users">
                <td>{{ user.username }}</td>
                <td>{{ user.fullName }}</td>
                <td><span class="badge bg-info text-dark">{{ user.roleName || 'No Role' }}</span></td>
                <td>
                  <span class="badge" [ngClass]="user.active ? 'bg-success' : 'bg-danger'">
                    {{ user.active ? 'Active' : 'Deactivated' }}
                  </span>
                </td>
                <td>
                   <button class="btn btn-sm btn-outline-primary me-2" (click)="selectUser(user)">Edit</button>
                   <button class="btn btn-sm btn-outline-danger" (click)="deleteUser(user.id)">Del</button>
                </td>
              </tr>
            </tbody>
          </table>
        </app-card>
      </div>
    </div>
  `
})
export class UsersComponent implements OnInit {
  users: any[] = [];
  roles: any[] = [];
  editUser: any = { username: '', fullName: '', password: '', roleId: null, active: true };
  http = inject(HttpClient);

  ngOnInit() {
    this.fetchData();
  }

  fetchData() {
    this.http.get(REST_URLS.USERS_LIST).subscribe((res: any) => this.users = res);
    this.http.get(REST_URLS.ROLES_LIST).subscribe((res: any) => this.roles = res);
  }

  selectUser(user: any) {
    this.editUser = { ...user, password: '' }; // Don't show old password hash/data
  }

  saveUser() {
    if (!this.editUser.username || !this.editUser.roleId) {
       alert("Please fill required fields (Username and Role)");
       return;
    }

    if (this.editUser.id) {
       this.http.put(`${REST_URLS.USERS_LIST}/${this.editUser.id}`, this.editUser).subscribe(() => {
          this.fetchData();
          this.resetForm();
       });
    } else {
       this.http.post(REST_URLS.USERS_LIST, this.editUser).subscribe(() => {
          this.fetchData();
          this.resetForm();
       });
    }
  }

  deleteUser(id: any) {
    if (confirm("Are you sure?")) {
      this.http.delete(`${REST_URLS.USERS_LIST}/${id}`).subscribe(() => this.fetchData());
    }
  }

  resetForm() {
    this.editUser = { username: '', fullName: '', password: '', roleId: null, active: true };
  }
}
