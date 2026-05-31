package com.mms.backend.config;

import com.mms.backend.entity.Role;
import com.mms.backend.entity.RolePermission;
import com.mms.backend.entity.User;
import com.mms.backend.repository.RolePermissionRepository;
import com.mms.backend.repository.RoleRepository;
import com.mms.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RolePermissionRepository rolePermissionRepository;

    @Override
    public void run(String... args) {
        if (roleRepository.count() == 0 || roleRepository.findByRoleName("Manager").isEmpty()) {
            // List of fundamental menus
            List<String> menus = List.of(
                    "Dashboard", "All Deposits", "New Deposit Entry",
                    "Customer Portfolio", "Merchant Transfers", "Download Reports",
                    "Backup & Restore", "System Settings", "Encryption Tool",
                    "Users", "Roles & Permissions");

            // 1. Create superAdmin (Tier 4: System Level)
            if (roleRepository.findByRoleName("superAdmin").isEmpty()) {
                Role role = roleRepository.save(new Role("superAdmin", "Full System & Security Access"));
                for (String menu : menus) {
                    rolePermissionRepository.save(new RolePermission(role, menu, true, true, true, true));
                }
            }

            // 2. Create Administrator (Tier 3: Business Management)
            if (roleRepository.findByRoleName("Administrator").isEmpty()) {
                Role role = roleRepository.save(new Role("Administrator", "Business administration with full record management"));
                for (String menu : menus) {
                    // Admins see all biz menus, but not critical system/security tools
                    boolean isBiz = !menu.contains("Settings") && !menu.contains("Encryption") && !menu.contains("Backup");
                    boolean isAdminModule = menu.equals("Users") || menu.contains("Roles");
                    rolePermissionRepository.save(new RolePermission(role, menu, isBiz || isAdminModule, isBiz, isBiz, false));
                }
            }

            // 3. Create Manager (Tier 2: Operational Supervisor)
            if (roleRepository.findByRoleName("Manager").isEmpty()) {
                Role role = roleRepository.save(new Role("Manager", "Operational supervisor with reporting and audit access"));
                for (String menu : menus) {
                    // Managers see Dashboard, Deposits, Portfolio, Reports
                    boolean isOps = menu.equals("Dashboard") || menu.contains("Deposit") || menu.contains("Portfolio") || menu.contains("Reports");
                    rolePermissionRepository.save(new RolePermission(role, menu, isOps, false, false, false));
                }
            }

            // 4. Create Cashier (Tier 1: Front-desk Entry)
            if (roleRepository.findByRoleName("Cashier").isEmpty()) {
                Role role = roleRepository.save(new Role("Cashier", "Front desk staff for new entries and basic list viewing"));
                List<String> allowed = List.of("Dashboard", "New Deposit Entry", "All Deposits");
                for (String menu : menus) {
                    boolean canUse = allowed.contains(menu);
                    rolePermissionRepository.save(new RolePermission(role, menu, canUse, canUse, false, false));
                }
            }
        }

        Optional<User> existingUserOpt = userRepository.findByUsername("yashmodi");
        if (existingUserOpt.isEmpty()) {
            Role superAdmin = roleRepository.findAll().stream()
                    .filter(r -> r.getRoleName().equals("superAdmin"))
                    .findFirst()
                    .orElse(null);

            User adminUser = new User();
            adminUser.setUsername("yashmodi");
            adminUser.setPassword("Admin@_1310");
            adminUser.setFullName("Yash Modi");
            adminUser.setActive(true);
            adminUser.setRole(superAdmin);
            userRepository.save(adminUser);
        }
    }
}
