package com.mms.backend.service;

import com.mms.backend.dto.DepositSummaryDTO;
import com.mms.backend.dto.MerchantItemDTO;
import com.mms.backend.entity.CustomerMaster;
import com.mms.backend.repository.CustomerMasterRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final DepositQueryService depositQueryService;
    private final MerchantService merchantService;
    private final CustomerMasterRepository customerRepository;

    public byte[] generateDepositsReport() throws IOException {
        List<DepositSummaryDTO> deposits = depositQueryService.getActiveDepositSummary();
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet(com.mms.backend.util.Constants.REPORT_SHEET_DEPOSITS);

            // Header
            Row headerRow = sheet.createRow(0);
            String[] columns = { "ID", "Customer Name", "Deposit Date", "Months", "Loan Amount", "Interest Rate",
                    "Status" };
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                CellStyle style = workbook.createCellStyle();
                Font font = workbook.createFont();
                font.setBold(true);
                style.setFont(font);
                cell.setCellStyle(style);
            }

            int rowIdx = 1;
            for (DepositSummaryDTO deposit : deposits) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(deposit.getDepositId());
                row.createCell(1).setCellValue(deposit.getCustomerName());
                row.createCell(2)
                        .setCellValue(deposit.getDepositDate() != null ? deposit.getDepositDate().toString() : "");
                row.createCell(3).setCellValue(
                        deposit.getDepositedMonths() != null ? deposit.getDepositedMonths().doubleValue() : 0.0);
                row.createCell(4)
                        .setCellValue(deposit.getTotalLoanAmount() != null ? deposit.getTotalLoanAmount().doubleValue()
                                : 0.0);
                row.createCell(5)
                        .setCellValue(deposit.getMonthlyInterest() != null ? deposit.getMonthlyInterest().doubleValue()
                                : 0.0);
                row.createCell(6).setCellValue(deposit.getStatus());
            }

            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return out.toByteArray();
        }
    }

    public byte[] generateCustomersReport() throws IOException {
        List<CustomerMaster> customers = customerRepository.findAll();
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet(com.mms.backend.util.Constants.REPORT_SHEET_CUSTOMERS);

            // Header
            Row headerRow = sheet.createRow(0);
            String[] columns = { "ID", "Name", "Mobile", "Email", "Address", "State", "City" };
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                CellStyle style = workbook.createCellStyle();
                Font font = workbook.createFont();
                font.setBold(true);
                style.setFont(font);
                cell.setCellStyle(style);
            }

            int rowIdx = 1;
            for (CustomerMaster customer : customers) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(customer.getId());
                row.createCell(1).setCellValue(customer.getCustomerName());
                row.createCell(2).setCellValue(customer.getMobileNumber());
                row.createCell(3).setCellValue(customer.getEmail());
                row.createCell(4).setCellValue(customer.getAddress());
                row.createCell(5).setCellValue(customer.getState());
                row.createCell(6).setCellValue(customer.getVillage());
            }

            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return out.toByteArray();
        }
    }

    public byte[] generateMerchantsReport() throws IOException {
        List<MerchantItemDTO> merchantEntries = merchantService.getActiveMerchantEntries();
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet(com.mms.backend.util.Constants.REPORT_SHEET_MERCHANT_TRANSFERS);

            // Header
            Row headerRow = sheet.createRow(0);
            String[] columns = { "ID", "Merchant Name", "Customer Name", "Item Name", "Principal", "Interest Rate",
                    "Months", "Status" };
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                CellStyle style = workbook.createCellStyle();
                Font font = workbook.createFont();
                font.setBold(true);
                style.setFont(font);
                cell.setCellStyle(style);
            }

            int rowIdx = 1;
            for (MerchantItemDTO entry : merchantEntries) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(entry.getEntryId());
                row.createCell(1).setCellValue(entry.getMerchantName());
                row.createCell(2).setCellValue(entry.getCustomerName());
                row.createCell(3).setCellValue(entry.getItemName());
                row.createCell(4).setCellValue(
                        entry.getPrincipalAmount() != null ? entry.getPrincipalAmount().doubleValue() : 0.0);
                row.createCell(5)
                        .setCellValue(entry.getInterestRate() != null ? entry.getInterestRate().doubleValue() : 0.0);
                row.createCell(6).setCellValue(entry.getMonthsDuration() != null ? entry.getMonthsDuration() : 0);
                row.createCell(7).setCellValue(entry.getStatus());
            }

            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return out.toByteArray();
        }
    }
}
