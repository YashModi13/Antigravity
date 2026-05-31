import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { REST_URLS } from '../shared/resturl';
import { MmsService } from '../mms.service';

@Component({
  selector: 'app-roles',
  standalone: true,
  imports: [CommonModule, FormsModule, SharedModule],
  template: `
    <div class="row animate__animated animate__fadeIn">
      <div class="col-sm-12">
        <div class="alert alert-info border-0 shadow-sm mb-4 d-flex align-items-center" *ngIf="mmsService.hasPermission('Roles & Permissions', 'view')">
           <i class="feather icon-info me-3 fs-4"></i>
           <div>
             <h6 class="m-0 fw-bold">Permission Aware UI</h6>
             <small>Your current role determines which buttons below are active. System Root (superAdmin) has full bypass.</small>
           </div>
        </div>

        <app-card cardTitle="Role & Permission Master" [options]="false">
          <div class="row align-items-center mb-4">
            <div class="col-md-8">
              <h5 class="text-primary fw-bold">Define Access Levels</h5>
              <p class="text-muted">Create roles and map which menus they can access and what actions they can perform.</p>
            </div>
          </div>

          <!-- Role Form Section -->
          <div class="card bg-light border-0 mb-4 shadow-none">
            <div class="card-body p-4">
              <div class="row g-3">
                <div class="col-md-4">
                  <label class="form-label">Role Name</label>
                  <input type="text" class="form-control" [(ngModel)]="editRole.roleName" 
                         placeholder="e.g. Manager, Cashier" [disabled]="editRole.roleName === 'superAdmin' || (!canAddRole() && !editRole.id)">
                </div>
                <div class="col-md-8">
                  <label class="form-label">Description</label>
                  <input type="text" class="form-control" [(ngModel)]="editRole.description" 
                         placeholder="Enter brief description of this role" [disabled]="!canEditRole() && editRole.id">
                </div>
              </div>

              <!-- Permission Table -->
              <div class="table-responsive mt-4" *ngIf="editRole.roleName">
                <table class="table table-hover table-bordered align-middle">
                  <thead class="bg-dark text-white text-center">
                    <tr>
                      <th class="text-start ps-4" style="width: 30%">System Menu / Module</th>
                      <th>View</th>
                      <th>Add</th>
                      <th>Edit</th>
                      <th>Delete</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr *ngFor="let p of editRole.permissions">
                      <td class="ps-4 fw-bold text-dark">{{ p.menuName }}</td>
                      <td class="text-center">
                        <div class="form-check form-switch d-inline-block">
                          <input class="form-check-input" type="checkbox" [(ngModel)]="p.canView" 
                                 [disabled]="editRole.roleName === 'superAdmin' || !canEditRole()">
                        </div>
                      </td>
                      <td class="text-center">
                        <div class="form-check form-switch d-inline-block">
                          <input class="form-check-input" type="checkbox" [(ngModel)]="p.canAdd" 
                                 [disabled]="editRole.roleName === 'superAdmin' || !canEditRole()">
                        </div>
                      </td>
                      <td class="text-center">
                        <div class="form-check form-switch d-inline-block">
                          <input class="form-check-input" type="checkbox" [(ngModel)]="p.canEdit" 
                                 [disabled]="editRole.roleName === 'superAdmin' || !canEditRole()">
                        </div>
                      </td>
                      <td class="text-center">
                        <div class="form-check form-switch d-inline-block">
                          <input class="form-check-input" type="checkbox" [(ngModel)]="p.canDelete" 
                                 [disabled]="editRole.roleName === 'superAdmin' || !canEditRole()">
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div class="mt-4 d-flex justify-content-end gap-2">
                <button class="btn btn-primary" (click)="saveRole()" 
                        [disabled]="(editRole.roleName === 'superAdmin' && editRole.id) || (!editRole.id && !canAddRole()) || (editRole.id && !canEditRole())">
                  <i class="feather icon-save me-2"></i> {{ editRole.id ? 'Update' : 'Create' }} Role
                </button>
                <button class="btn btn-outline-secondary" (click)="resetForm()">
                  <i class="feather icon-rotate-ccw me-2"></i> Reset
                </button>
              </div>
            </div>
          </div>

          <hr class="my-5"/>

          <!-- Roles Table Section -->
          <div class="d-flex justify-content-between align-items-center mb-4">
             <h5 class="fw-bold m-0"><i class="feather icon-list me-2"></i> Existing Roles</h5>
          </div>

          <div class="table-responsive">
            <table class="table table-hover align-middle">
              <thead>
                <tr>
                  <th>Role</th>
                  <th>Description</th>
                  <th class="text-center">Active Permissions</th>
                  <th class="text-end pe-4">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr *ngFor="let role of roles">
                  <td>
                    <span class="badge bg-light-primary text-primary px-3 py-2 fw-bold" style="font-size: 0.9rem;">
                      {{ role.roleName }}
                    </span>
                  </td>
                  <td class="text-muted">{{ role.description }}</td>
                  <td class="text-center">
                    <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2">
                       {{ getActiveMenuCount(role) }} Active Menus
                    </span>
                  </td>
                  <td class="text-end pe-4">
                    <button class="btn btn-icon btn-outline-primary btn-sm me-2" (click)="selectRole(role)" 
                            [disabled]="!canEditRole() && role.roleName !== 'superAdmin'" title="Edit Role">
                      <i class="feather icon-edit-2"></i>
                    </button>
                    <button class="btn btn-icon btn-outline-danger btn-sm" (click)="deleteRole(role.id)" 
                            [disabled]="role.roleName === 'superAdmin' || !canDeleteRole()" title="Delete Role">
                      <i class="feather icon-trash-2"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </app-card>
      </div>
    </div>
  `,
  styles: [`
    .bg-success-subtle { background-color: rgba(16, 185, 129, 0.1) !important; color: #059669 !important; border: 1px solid rgba(16, 185, 129, 0.2) !important; }
    .bg-light-primary { background-color: rgba(59, 130, 246, 0.1) !important; color: #2563eb !important; }
  `]
})
export class RolesComponent implements OnInit {
  roles: any[] = [];
  menus = [
    "Dashboard", "All Deposits", "New Deposit Entry",
    "Customer Portfolio", "Merchant Transfers", "Download Reports",
    "Backup & Restore", "System Settings", "Encryption Tool",
    "Users", "Roles & Permissions"
  ];

  editRole: any = { roleName: '', description: '', permissions: [] };
  http = inject(HttpClient);
  mmsService = inject(MmsService);

  ngOnInit() {
    this.fetchData();
    this.resetForm();
  }

  canAddRole(): boolean {
    return this.mmsService.hasPermission('Roles & Permissions', 'add');
  }

  canEditRole(): boolean {
    return this.mmsService.hasPermission('Roles & Permissions', 'edit');
  }

  canDeleteRole(): boolean {
    return this.mmsService.hasPermission('Roles & Permissions', 'delete');
  }

  getActiveMenuCount(role: any): number {
    return role.permissions?.filter((p: any) => p.canView).length || 0;
  }

  fetchData() {
    this.http.get(REST_URLS.ROLES_LIST).subscribe((res: any) => this.roles = res);
  }

  resetForm() {
    this.editRole = {
      roleName: '',
      description: '',
      permissions: this.menus.map(m => ({
        menuName: m,
        canView: false,
        canAdd: false,
        canEdit: false,
        canDelete: false
      }))
    };
  }

  selectRole(role: any) {
    // Clone and ensure all menus exist in editRole permissions
    const mappedPerms = this.menus.map(m => {
       const existing = role.permissions.find((p: any) => p.menuName === m);
       return existing ? { ...existing } : { menuName: m, canView: false, canAdd: false, canEdit: false, canDelete: false };
    });
    this.editRole = { ...role, permissions: mappedPerms };
  }

  saveRole() {
    if (!this.editRole.roleName) {
      alert("Role Name is required");
      return;
    }

    if (this.editRole.id) {
      this.http.put(`${REST_URLS.ROLES_LIST}/${this.editRole.id}`, this.editRole).subscribe(() => {
        this.fetchData();
        this.resetForm();
      });
    } else {
      this.http.post(REST_URLS.ROLES_LIST, this.editRole).subscribe(() => {
        this.fetchData();
        this.resetForm();
      });
    }
  }

  deleteRole(id: any) {
    if (confirm("Deleting a role will affect users assigned to it. Continue?")) {
      this.http.delete(`${REST_URLS.ROLES_LIST}/${id}`).subscribe(() => this.fetchData());
    }
  }
}
