package com.mms.backend.service;

import com.mms.backend.entity.*;
import com.mms.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Random;

@Service
public class DemoDataService {

    @Autowired
    private CustomerMasterRepository customerRepo;
    @Autowired
    private CustomerDepositEntryRepository depositRepo;
    @Autowired
    private CustomerDepositItemsRepository itemsRepo;
    @Autowired
    private CustomerDepositTransactionRepository txRepo;
    @Autowired
    private UnitMasterRepository unitRepo;
    @Autowired
    private ItemMasterRepository itemRepo;
    @Autowired
    private ItemPriceHistoryRepository priceRepo;

    private final Random random = new Random();

    @Transactional
    public void generateDemoData(int count) {
        // Ensure masters exist
        if (unitRepo.count() == 0 || priceRepo.count() == 0) {
            createMasterData();
        }

        UnitMaster gram = unitRepo.findAll().stream().filter(u -> "GRAM".equals(u.getUnitName())).findFirst()
                .orElseThrow();
        ItemMaster gold = itemRepo.findByItemCode("GOLD");

        if (gold == null) {
            // Create if missing (sanity check)
            gold = new ItemMaster();
            gold.setItemName("GOLD");
            gold.setItemCode("GOLD");
            gold.setUnit(gram);
            gold.setUnitQuantity(BigDecimal.TEN);
            gold = itemRepo.save(gold);
        }

        String[] names = { "Rajesh Kumar", "Suresh Patel", "Amit Shah", "Priya Desai", "Vikram Singh",
                "Anita Mehta", "Ramesh Gupta", "Sanjay Joshi", "Meera Iyer", "Rahul Dravid" };

        for (int i = 0; i < count; i++) {
            // 1. Create Customer
            CustomerMaster cust = new CustomerMaster();
            cust.setCustomerName(names[random.nextInt(names.length)] + " " + random.nextInt(100));
            cust.setMobileNumber("98" + (10000000 + random.nextInt(90000000)));
            cust.setVillage("Demo Village");
            cust.setCreatedDate(LocalDateTime.now());
            cust = customerRepo.save(cust);

            // 2. Create Deposit
            CustomerDepositEntry deposit = new CustomerDepositEntry();
            deposit.setCustomer(cust);
            // Random date in last 30 days
            deposit.setDepositDate(LocalDate.now().minusDays(random.nextInt(30)));
            deposit.setTotalInterestRate(new BigDecimal("2.0"));
            deposit.setCreatedDate(LocalDateTime.now());
            deposit = depositRepo.save(deposit);

            // 3. Create Item (Gold Ring/Chain)
            CustomerDepositItems item = new CustomerDepositItems();
            item.setDepositEntry(deposit);
            item.setItem(gold);
            item.setItemDate(deposit.getDepositDate());
            double weight = 10 + random.nextDouble() * 50; // 10g to 60g
            item.setWeightReceived(BigDecimal.valueOf(weight));
            item.setWeightUnit(gram);
            item.setFineWeight(BigDecimal.valueOf(weight * 0.90)); // 90% purity
            item.setItemDescription("Gold Ornament Demo " + i);
            item.setCreatedDate(LocalDateTime.now());
            itemsRepo.save(item);

            // 4. Initial Transaction
            CustomerDepositTransaction tx = new CustomerDepositTransaction();
            tx.setDepositEntry(deposit);
            tx.setTransactionType("INITIAL_MONEY");
            // Loan amount: 70% of value (approx 5000 per gram)
            BigDecimal loan = BigDecimal.valueOf(weight * 5000 * 0.70);
            tx.setAmount(loan);
            tx.setTransactionDate(deposit.getDepositDate());
            tx.setCreatedDate(LocalDateTime.now());
            txRepo.save(tx);
        }
    }

    private void createMasterData() {
        // Fallback if SQL didn't run
        UnitMaster gram = new UnitMaster();
        gram.setUnitName("GRAM");
        gram.setUnitInGram(BigDecimal.ONE);
        unitRepo.save(gram);

        ItemMaster gold = new ItemMaster();
        gold.setItemName("GOLD");
        gold.setItemCode("GOLD");
        gold.setUnit(gram);
        gold.setUnitQuantity(BigDecimal.TEN);
        gold = itemRepo.save(gold);

        // Seed Initial Price for Gold (per 10 GRAM)
        ItemPriceHistory goldPrice = new ItemPriceHistory();
        goldPrice.setItem(gold);
        goldPrice.setPrice(new BigDecimal("75000.00"));
        goldPrice.setEffectiveDate(LocalDate.now());
        goldPrice.setIsActive(true);
        goldPrice.setCreatedDate(LocalDateTime.now());
        priceRepo.save(goldPrice);

        // Seed Silver (per 1 KG)
        UnitMaster kg = new UnitMaster();
        kg.setUnitName("KG");
        kg.setUnitInGram(new BigDecimal("1000.000"));
        unitRepo.save(kg);

        ItemMaster silver = new ItemMaster();
        silver.setItemName("SILVER");
        silver.setItemCode("SILVER");
        silver.setUnit(kg);
        silver.setUnitQuantity(BigDecimal.ONE);
        silver = itemRepo.save(silver);

        ItemPriceHistory silverPrice = new ItemPriceHistory();
        silverPrice.setItem(silver);
        silverPrice.setPrice(new BigDecimal("95000.00"));
        silverPrice.setEffectiveDate(LocalDate.now());
        silverPrice.setIsActive(true);
        silverPrice.setCreatedDate(LocalDateTime.now());
        priceRepo.save(silverPrice);

        // Seed Platinum
        ItemMaster platinum = new ItemMaster();
        platinum.setItemName("PLATINUM");
        platinum.setItemCode("PLAT");
        platinum.setUnit(gram);
        platinum.setUnitQuantity(BigDecimal.ONE);
        platinum = itemRepo.save(platinum);

        ItemPriceHistory platPrice = new ItemPriceHistory();
        platPrice.setItem(platinum);
        platPrice.setPrice(new BigDecimal("3500.00"));
        platPrice.setEffectiveDate(LocalDate.now());
        platPrice.setIsActive(true);
        platPrice.setCreatedDate(LocalDateTime.now());
        priceRepo.save(platPrice);
    }
}
