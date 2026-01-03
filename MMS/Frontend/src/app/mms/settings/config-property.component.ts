import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { FormsModule } from '@angular/forms';
import { MmsService, ConfigProperty } from '../mms.service';
import { ToastService } from 'src/app/theme/shared/components/toast/toast.service';
import { RECOMMENDED_CONFIGS } from '../shared/constant';

@Component({
    selector: 'app-config-property',
    standalone: true,
    imports: [CommonModule, SharedModule, FormsModule],
    templateUrl: './config-property.component.html'
})
export class ConfigPropertyComponent implements OnInit {
    configs: ConfigProperty[] = [];
    currentConfig: ConfigProperty = { propertyKey: '', propertyValue: '', description: '', isActive: true };
    showModal = false;
    isEdit = false;

    // Sync Feature State
    showSyncModal = false;
    differenceConfigs: any[] = [];
    recommendedConfigs = RECOMMENDED_CONFIGS;

    constructor(private mmsService: MmsService, private toastService: ToastService) { }

    ngOnInit() {
        this.loadConfigs();
    }

    loadConfigs() {
        this.mmsService.getAllConfigs().subscribe({
            next: (data) => this.configs = data,
            error: () => this.toastService.error('Failed to load settings')
        });
    }

    checkDefaults() {
        this.differenceConfigs = [];
        this.recommendedConfigs.forEach(rec => {
            const existing = this.configs.find(c => c.propertyKey === rec.key);
            if (!existing) {
                this.differenceConfigs.push({
                    key: rec.key,
                    recommendedValue: rec.val,
                    currentValue: '(Missing)',
                    description: rec.desc,
                    type: 'MISSING',
                    selected: true
                });
            } else if (existing.propertyValue !== rec.val) {
                this.differenceConfigs.push({
                    key: rec.key,
                    recommendedValue: rec.val,
                    currentValue: existing.propertyValue,
                    description: rec.desc,
                    type: 'DIFFERENT',
                    selected: false,
                    id: existing.id
                });
            }
        });

        if (this.differenceConfigs.length === 0) {
            this.toastService.success('All settings are already up to date!');
        } else {
            this.showSyncModal = true;
        }
    }

    syncSelected() {
        const toSync = this.differenceConfigs.filter(c => c.selected);
        if (toSync.length === 0) {
            this.showSyncModal = false;
            return;
        }

        let completed = 0;
        toSync.forEach(item => {
            const config: ConfigProperty = {
                id: item.id,
                propertyKey: item.key,
                propertyValue: item.recommendedValue,
                description: item.description,
                isActive: true
            };

            this.mmsService.saveConfig(config).subscribe({
                next: () => {
                    completed++;
                    if (completed === toSync.length) {
                        this.toastService.success(`Successfully synced ${completed} properties!`);
                        this.showSyncModal = false;
                        this.loadConfigs();
                    }
                }
            });
        });
    }

    openAddModal() {
        this.isEdit = false;
        this.currentConfig = { propertyKey: '', propertyValue: '', description: '', isActive: true };
        this.showModal = true;
    }

    editConfig(config: ConfigProperty) {
        this.isEdit = true;
        this.currentConfig = { ...config };
        this.showModal = true;
    }

    deleteConfig(id: number) {
        if (confirm('Are you sure you want to delete this setting?')) {
            this.mmsService.deleteConfig(id).subscribe({
                next: () => {
                    this.toastService.success('Setting deleted');
                    this.loadConfigs();
                },
                error: () => this.toastService.error('Failed to delete setting')
            });
        }
    }

    saveConfig() {
        if (!this.currentConfig.propertyKey || !this.currentConfig.propertyValue) {
            this.toastService.error('Key and Value are required');
            return;
        }

        this.mmsService.saveConfig(this.currentConfig).subscribe({
            next: () => {
                this.toastService.success(this.isEdit ? 'Setting updated' : 'Setting created');
                this.showModal = false;
                this.loadConfigs();
            },
            error: () => this.toastService.error('Error saving setting')
        });
    }
}

