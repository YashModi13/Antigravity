package com.mms.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;
import com.mms.backend.repository.ConfigPropertyRepository;
import com.mms.backend.entity.ConfigProperty;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
public class DatabaseBackupService {

    @Autowired
    private ConfigPropertyRepository configRepository;

    private String getRequiredConfig(String key) {
        return configRepository.findByPropertyKey(key)
                .map(ConfigProperty::getPropertyValue)
                .filter(val -> !val.trim().isEmpty())
                .orElseThrow(() -> new RuntimeException(
                        "CRITICAL ERROR: Configuration property '" + key + "' is missing in database."));
    }

    private String getPgDumpPath() {
        String path = getRequiredConfig("PG_DUMP_PATH");
        if (!new File(path).exists())
            throw new RuntimeException("pg_dump not found at: " + path);
        return path;
    }

    public byte[] generateBackup() throws IOException, InterruptedException {
        String executable = getPgDumpPath();
        String host = getRequiredConfig("DB_HOST");
        String port = getRequiredConfig("DB_PORT");
        String dbUser = getRequiredConfig("DB_USER");
        String dbPass = getRequiredConfig("DB_PASS");
        String dbName = getRequiredConfig("DB_NAME");
        String schema = getRequiredConfig("BACKUP_SCHEMA");

        File tempFile = File.createTempFile("mms_backup_", ".sql");
        List<String> command = new ArrayList<>();
        command.add(executable);
        command.add("-h");
        command.add(host);
        command.add("-p");
        command.add(port);
        command.add("-U");
        command.add(dbUser);
        command.add("-n");
        command.add(schema);
        command.add("-f");
        command.add(tempFile.getAbsolutePath());
        command.add(dbName);

        ProcessBuilder pb = new ProcessBuilder(command);
        pb.environment().put("PGPASSWORD", dbPass);
        pb.redirectErrorStream(true);
        Process process = pb.start();

        java.io.BufferedReader reader = new java.io.BufferedReader(
                new java.io.InputStreamReader(process.getInputStream()));
        while (reader.readLine() != null)
            ; // Drain output

        int exitCode = process.waitFor();
        if (exitCode == 0) {
            byte[] data = Files.readAllBytes(tempFile.toPath());
            tempFile.delete();
            return data;
        } else {
            tempFile.delete();
            throw new IOException("Backup failed.");
        }
    }

    /**
     * Restores a backup using parameters provided from the UI.
     */
    public void restoreBackup(byte[] backupData, String host, String port, String user, String pass, String db,
            String schema, String psqlPath) throws IOException, InterruptedException {
        log.info("Starting database restore process for schema: {} using parameters from UI", schema);

        // 1. Verify psql path
        if (!new File(psqlPath).exists()) {
            throw new IOException("Restore failed: psql executable not found at " + psqlPath);
        }

        // 2. Write uploaded backup to a temp file
        File restoreFile = File.createTempFile("mms_restore_", ".sql");
        try (FileOutputStream fos = new FileOutputStream(restoreFile)) {
            fos.write(backupData);
        }

        try {
            // 3. Drop and Recreate Schema (Clean state)
            log.info("Wiping and recreating schema '{}'...", schema);
            executePsqlCommand(psqlPath, host, port, user, pass, db,
                    "DROP SCHEMA IF EXISTS " + schema + " CASCADE; CREATE SCHEMA " + schema + ";");

            // 4. Restore Backup
            log.info("Importing data into database...");
            List<String> restoreCmd = new ArrayList<>();
            restoreCmd.add(psqlPath);
            restoreCmd.add("-h");
            restoreCmd.add(host);
            restoreCmd.add("-p");
            restoreCmd.add(port);
            restoreCmd.add("-U");
            restoreCmd.add(user);
            restoreCmd.add("-f");
            restoreCmd.add(restoreFile.getAbsolutePath());
            restoreCmd.add(db);

            ProcessBuilder pb = new ProcessBuilder(restoreCmd);
            pb.environment().put("PGPASSWORD", pass);
            pb.redirectErrorStream(true);
            Process process = pb.start();

            java.io.BufferedReader reader = new java.io.BufferedReader(
                    new java.io.InputStreamReader(process.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null)
                log.info("[psql-restore] {}", line);

            int exitCode = process.waitFor();
            if (exitCode != 0) {
                throw new IOException("Restore failed. psql exit code: " + exitCode);
            }
            log.info("Database restore completed successfully.");

        } finally {
            if (restoreFile.exists())
                restoreFile.delete();
        }
    }

    private void executePsqlCommand(String psql, String host, String port, String user, String pass, String db,
            String sql) throws IOException, InterruptedException {
        List<String> cmd = new ArrayList<>();
        cmd.add(psql);
        cmd.add("-h");
        cmd.add(host);
        cmd.add("-p");
        cmd.add(port);
        cmd.add("-U");
        cmd.add(user);
        cmd.add("-c");
        cmd.add(sql);
        cmd.add(db);

        ProcessBuilder pb = new ProcessBuilder(cmd);
        pb.environment().put("PGPASSWORD", pass);
        pb.redirectErrorStream(true);
        Process process = pb.start();

        java.io.BufferedReader reader = new java.io.BufferedReader(
                new java.io.InputStreamReader(process.getInputStream()));
        while (reader.readLine() != null)
            ;

        int exitCode = process.waitFor();
        if (exitCode != 0)
            throw new IOException("Failed to execute psql command.");
    }
}
