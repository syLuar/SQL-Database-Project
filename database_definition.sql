--- Queries all in MS SQL Server
--- Act 2: Creating tables

-- Table 1: UserAccount(uid, gender, DoB, name)
-- Entity Set
CREATE TABLE UserAccount (
    uid CHAR(10) PRIMARY KEY,
    gender VARCHAR(1) CHECK(gender IN ('M', 'F', 'O')),
    DoB DATE NOT NULL,
    name VARCHAR(20) UNIQUE NOT NULL,
    address CHAR(6) NOT NULL
);

-- Table 2: Related(uid1, uid2, type)
-- Many-Many R/S
CREATE TABLE Related (
    uid1 CHAR(10) NOT NULL,
    uid2 CHAR(10) NOT NULL,
    type VARCHAR(10) CHECK(type IN ('friend', 'family', 'colleague', 'club')),

    PRIMARY KEY (uid1, uid2),
    FOREIGN KEY (uid1) REFERENCES UserAccount(uid),
    FOREIGN KEY (uid2) REFERENCES UserAccount(uid)
);

-- Table 9: MallChain(chainid, address)
-- Entity Set
CREATE TABLE MallChain (
    chainid CHAR(10) PRIMARY KEY,
    address CHAR(6) NOT NULL -- SG Postal Code
);

-- Table 8: Mall(mid, chainid, address, numShops)
-- Entity Set
CREATE TABLE Mall (
    mid CHAR(10) PRIMARY KEY,
    chainid CHAR(10) NOT NULL,
    address CHAR(6) NOT NULL, -- SG Postal Code
    numShops INT NOT NULL CHECK(numShops >= 0),

    FOREIGN KEY (chainid) REFERENCES MallChain(chainid)
);

-- Table 3: Shop(sid, mid, type)
-- Entity Set
CREATE TABLE Shop (
    sid CHAR(10) PRIMARY KEY,
    mid CHAR(10) NOT NULL,
    type VARCHAR(50),

    FOREIGN KEY (mid) REFERENCES Mall(mid)
);

-- Table 4: ShopRecord(sid, uid, amountSpent, datetimeIn, datetimeOut)
-- Weak Entity Set
CREATE TABLE ShopRecord (
    sid CHAR(10) NOT NULL,
    uid CHAR(10) NOT NULL,
    amountSpent FLOAT NOT NULL,
    datetimeIn DATE NOT NULL,
    datetimeOut DATE NOT NULL,

    PRIMARY KEY (sid, uid, datetimeIn),
    FOREIGN KEY (sid) REFERENCES Shop(sid),
    FOREIGN KEY (uid) REFERENCES UserAccount(uid)
);

-- Table 6: RestaurantChain(rid, address)
-- Entity Set
CREATE TABLE RestaurantChain (
    rid CHAR(10) PRIMARY KEY,
    address CHAR(6) NOT NULL -- SG Postal Code
);

-- Table 5: RestaurantOutlet(oid, rid, mid)
-- Entity Set
CREATE TABLE RestaurantOutlet (
    oid CHAR(10) PRIMARY KEY,
    rid CHAR(10) NOT NULL,
    mid CHAR(10) NOT NULL,

    FOREIGN KEY (rid) REFERENCES RestaurantChain(rid),
    FOREIGN KEY (mid) REFERENCES Mall(mid)
);



-- Table 7: DineRecord(oid, uid, amountSpent, datetimeIn, datetimeOut)
-- Weak Entity Set
CREATE TABLE DineRecord (
    oid CHAR(10) NOT NULL,
    uid CHAR(10) NOT NULL,
    amountSpent FLOAT NOT NULL,
    datetimeIn DATE NOT NULL,
    datetimeOut DATE NOT NULL,

    PRIMARY KEY (oid, uid, datetimeIn),
    FOREIGN KEY (oid) REFERENCES RestaurantOutlet(oid),
    FOREIGN KEY (uid) REFERENCES UserAccount(uid)
);





-- Table 10: Complaint(cid, uid, text, status, datetimeFiled, complaintQNo)
-- Entity Set
CREATE TABLE Complaint (
    cid CHAR(10) PRIMARY KEY,
    uid CHAR(10) NOT NULL,
    text VARCHAR(250) NOT NULL,
    status VARCHAR(20) CHECK(status IN ('pending', 'being handled', 'addressed')),
    datetimeFiled DATE NOT NULL,
    complaintQNo INT NOT NULL CHECK(complaintQNo >= 1),

    FOREIGN KEY (uid) REFERENCES UserAccount(uid)
);

-- Table 11: Shop Complaint
-- Entity Set
-- 11A: ShopComplaint(cid, uid, sid, text, status, datetimeFiled)
CREATE TABLE ShopComplaint (
    cid CHAR(10) PRIMARY KEY,
    uid CHAR(10) NOT NULL,
    sid CHAR(10) NOT NULL,
    text VARCHAR(250) NOT NULL,
    status VARCHAR(20) CHECK(status IN ('pending', 'being handled', 'addressed')),
    datetimeFiled DATE NOT NULL,

    FOREIGN KEY (cid) REFERENCES Complaint(cid),
    FOREIGN KEY (uid) REFERENCES UserAccount(uid),
    FOREIGN KEY (sid) REFERENCES Shop(sid)
);

-- 11B: ShopComplaintQueue(sid, complaintQNo)
CREATE TABLE ShopComplaintQueue (
    sid CHAR(10) NOT NULL,
    complaintQNo INT NOT NULL CHECK(complaintQNo >= 1),

    PRIMARY KEY (sid, complaintQNo),
    FOREIGN KEY (sid) REFERENCES Shop(sid)
);

-- Table 12: Restaurant Complaint
-- Entity Set
-- 12A: RestaurantComplaint(cid, uid, oid, text, status, datetimeFiled)
CREATE TABLE RestaurantComplaint (
    cid CHAR(10) PRIMARY KEY,
    uid CHAR(10) NOT NULL,
    oid CHAR(10) NOT NULL,
    text VARCHAR(250) NOT NULL,
    status VARCHAR(20) CHECK(status IN ('pending', 'being handled', 'addressed')),
    datetimeFiled DATE NOT NULL,

    FOREIGN KEY (cid) REFERENCES Complaint(cid),
    FOREIGN KEY (uid) REFERENCES UserAccount(uid),
    FOREIGN KEY (oid) REFERENCES RestaurantOutlet(oid)
);

-- 12B: RestaurantComplaintQueue(oid, complaintQNo)
CREATE TABLE RestaurantComplaintQueue (
    oid CHAR(10) NOT NULL,
    complaintQNo INT NOT NULL CHECK(complaintQNo >= 1),

    PRIMARY KEY (oid, complaintQNo),
    FOREIGN KEY (oid) REFERENCES RestaurantOutlet(oid)
);

-- Table 13: Voucher(vid, status, description, dateIssued, dateExpire)
-- Entity Set
CREATE TABLE Voucher (
    vid CHAR(10) PRIMARY KEY,
    status VARCHAR(10) CHECK(status IN ('allocated', 'redeemed', 'expired')),
    description VARCHAR(250) NOT NULL,
    dateIssued DATE NOT NULL,
    dateExpire DATE NOT NULL
);

-- Table 14: Purchase Voucher
-- Entity Set
-- 14A: PurchaseVoucher(vid, description, dateIssued, dateExpire uid, purchaseDiscount, datetimeUsed)
CREATE TABLE PurchaseVoucher (
    vid CHAR(10) PRIMARY KEY,
    description VARCHAR(250) NOT NULL,
    dateIssued DATE NOT NULL,
    dateExpire DATE NOT NULL,
    uid CHAR(10) NOT NULL,
    purchaseDiscount FLOAT NOT NULL CHECK(purchaseDiscount BETWEEN 0 AND 1),
    datetimeUsed DATE NOT NULL,

    FOREIGN KEY (uid) REFERENCES UserAccount(uid)
);

-- 14B: PurchaseVoucherStatus(dateIssued, dateExpire, datetimeUsed, status)
CREATE TABLE PurchaseVoucherStatus (
    dateIssued DATE NOT NULL,
    dateExpire DATE NOT NULL,
    datetimeUsed DATE NOT NULL,
    status VARCHAR(10) CHECK(status IN ('allocated', 'redeemed', 'expired')),

    PRIMARY KEY (dateIssued, dateExpire, datetimeUsed, status)
);

-- Table 15: Dine Voucher
-- Entity Set
-- 15A: DineVoucher(vid, description, dateIssued, dateExpire uid, cashDiscount, datetimeUsed)
CREATE TABLE DineVoucher (
    vid CHAR(10) PRIMARY KEY,
    description VARCHAR(250) NOT NULL,
    dateIssued DATE NOT NULL,
    dateExpire DATE NOT NULL,
    uid CHAR(10) NOT NULL,
    cashDiscount FLOAT NOT NULL CHECK(cashDiscount >= 0),
    datetimeUsed DATE NOT NULL,

    FOREIGN KEY (uid) REFERENCES UserAccount(uid)
);

-- 15B: DineVoucherStatus(dateIssued, dateExpire, datetimeUsed, status)
CREATE TABLE DineVoucherStatus (
    dateIssued DATE NOT NULL,
    dateExpire DATE NOT NULL,
    datetimeUsed DATE NOT NULL,
    status VARCHAR(10) CHECK(status IN ('allocated', 'redeemed', 'expired')),

    PRIMARY KEY (dateIssued, dateExpire, datetimeUsed, status)
);

-- Table 16: Group Voucher
-- Entity Set
-- 16A: GroupVoucher(vid, description, dateIssued, dateExpire uid, cashDiscount, datetimeUsed)
CREATE TABLE GroupVoucher (
    vid CHAR(10) PRIMARY KEY,
    description VARCHAR(250) NOT NULL,
    dateIssued DATE NOT NULL,
    dateExpire DATE NOT NULL,
    uid CHAR(10) NOT NULL,
    groupDiscount FLOAT NOT NULL CHECK(groupDiscount >= 0),
    datetimeUsed DATE NOT NULL,

    FOREIGN KEY (uid) REFERENCES UserAccount(uid)
);

-- 16B: GroupVoucherStatus(dateIssued, dateExpire, datetimeUsed, status)
CREATE TABLE GroupVoucherStatus (
    dateIssued DATE NOT NULL,
    dateExpire DATE NOT NULL,
    datetimeUsed DATE NOT NULL,
    status VARCHAR(10) CHECK(status IN ('allocated', 'redeemed', 'expired')),

    PRIMARY KEY (dateIssued, dateExpire, datetimeUsed, status)
);

-- Table 17: PackageVoucher(vid, status, description, dateIssued, dateExpire, packageDiscount)
-- Entity Set
CREATE TABLE PackageVoucher (
    vid CHAR(10) PRIMARY KEY,
    status VARCHAR(10) CHECK(status IN ('allocated', 'redeemed', 'expired')),
    description VARCHAR(250) NOT NULL,
    dateIssued DATE NOT NULL,
    dateExpire DATE NOT NULL,
    packageDiscount FLOAT NOT NULL CHECK(packageDiscount >= 0)
);

-- Table 18: DayPackage(did, vid, uid, description)
-- Entity Set
CREATE TABLE DayPackage (
    did CHAR(10) NOT NULL,
    vid CHAR(10) NOT NULL,
    uid CHAR(10) NOT NULL,
    description VARCHAR(250) NOT NULL,

    PRIMARY KEY (did, uid),
    FOREIGN KEY (vid) REFERENCES PackageVoucher(vid),
    FOREIGN KEY (uid) REFERENCES UserAccount(uid)
);

-- Table 19: MallPackage(mid, did)
-- Many-Many R/S
CREATE TABLE MallPackage (
    mid CHAR(10) NOT NULL,
    did CHAR(10) NOT NULL,
	uid CHAR(10) NOT NULL,

    PRIMARY KEY (mid, did),
    FOREIGN KEY (mid) REFERENCES Mall(mid),
    FOREIGN KEY (did, uid) REFERENCES DayPackage(did, uid)
);

-- Table 20: RestaurantOutletPackage(oid, did)
-- Many-Many R/S
CREATE TABLE RestaurantOutletPackage (
    oid CHAR(10) NOT NULL,
    did CHAR(10) NOT NULL,
	uid CHAR(10) NOT NULL,

    PRIMARY KEY (oid, did),
    FOREIGN KEY (oid) REFERENCES RestaurantOutlet(oid),
    FOREIGN KEY (did, uid) REFERENCES DayPackage(did, uid)
);

-- Table 21: Recommendation
-- Entity Set
-- 21A: Recommendation(nid, did, validPeriod, dateIssued)
CREATE TABLE Recommendation (
    nid CHAR(10) PRIMARY KEY,
    did CHAR(10) NOT NULL,
    validPeriod INT NOT NULL CHECK(validPeriod >= 0),
    dateIssued DATE NOT NULL,
	uid CHAR(10) NOT NULL,

    FOREIGN KEY (did, uid) REFERENCES DayPackage(did, uid)
);

-- 21B: ReccMallVouchers(purchase_vid, mid)
CREATE TABLE ReccMallVouchers (
    purchase_vid CHAR(10) NOT NULL,
    mid CHAR(10) NOT NULL,

    PRIMARY KEY (purchase_vid),
    FOREIGN KEY (purchase_vid) REFERENCES PurchaseVoucher(vid),
    FOREIGN KEY (mid) REFERENCES Mall(mid)
);

-- 21C: ReccRestaurantVouchers(dine_vid, oid)
CREATE TABLE ReccRestaurantVouchers (
    dine_vid CHAR(10) NOT NULL,
    oid CHAR(10) NOT NULL,
    did CHAR(10) NOT NULL,
	mid CHAR(10) NOT NULL,


    PRIMARY KEY (dine_vid),
    FOREIGN KEY (mid, did) REFERENCES MallPackage(mid, did),
    FOREIGN KEY (oid) REFERENCES RestaurantOutlet(oid)
);

-- 21D: ReccPackageVouchers(purchase_vid, dine_vid, did)
CREATE TABLE ReccPackageVouchers (
    purchase_vid CHAR(10) NOT NULL,
    dine_vid CHAR(10) NOT NULL,
    did CHAR(10) NOT NULL,
	uid CHAR(10) NOT NULL,

    PRIMARY KEY (purchase_vid, dine_vid),
    FOREIGN KEY (purchase_vid) REFERENCES PurchaseVoucher(vid),
    FOREIGN KEY (dine_vid) REFERENCES DineVoucher(vid),
    FOREIGN KEY (did, uid) REFERENCES DayPackage(did, uid)
);

-- Table 22: UserAccountRecommendation(uid, nid)
-- Many-Many R/S
CREATE TABLE UserAccountRecommendation (
    uid CHAR(10) NOT NULL,
    nid CHAR(10) NOT NULL,

    PRIMARY KEY (uid, nid),
    FOREIGN KEY (uid) REFERENCES UserAccount(uid),
    FOREIGN KEY (nid) REFERENCES Recommendation(nid)
);


--- Queries all in MS SQL Server
--- Act 3: Inserting Tuples
-- Insert 5 tuples per Table

-- Table 1: UserAccount(uid, gender, DoB, name, address)
INSERT INTO UserAccount VALUES
('U000000001', 'M', '1990-01-01', 'John Doe', '123456'),
('U000000002', 'F', '1995-02-02', 'Jane Doe', '123456'),
('U000000003', 'M', '2000-03-03', 'Jack Doe', '123456'),
('U000000004', 'F', '2005-04-04', 'Jill Doe', '654321'),
('U000000005', 'M', '2010-05-05', 'Jim Doe', '654321'),
('U000000006', 'M', '2010-05-05', 'Jail Doe', '654321'),
('U000000007', 'M', '2010-05-05', 'Jailer Doe', '135789'),
('U000000008', 'M', '2010-05-05', 'Jailed Doe', '135789'),
('U000000009', 'M', '2010-05-05', 'Joe Doe', '696969'),
('U000000010', 'M', '2010-05-05', 'Joey Doe', '696969');

-- Table 2: Related(uid1, uid2, type)
INSERT INTO Related VALUES
('U000000001', 'U000000002', 'family'),
('U000000001', 'U000000003', 'family'),
('U000000002', 'U000000003', 'family'),
('U000000004', 'U000000005', 'family'),
('U000000005', 'U000000006', 'family'),
('U000000004', 'U000000006', 'family'),
('U000000004', 'U000000007', 'colleague'),
('U000000003', 'U000000008', 'club'),
('U000000006', 'U000000007', 'friend'),
('U000000007', 'U000000008', 'family'),
('U000000009', 'U000000010', 'family');

-- Table 9: MallMgmtCompany(chainid, address)
INSERT INTO MallChain VALUES
('C000000001', '123456'),
('C000000002', '456789'),
('C000000003', '789012'),
('C000000004', '012345'),
('C000000005', '345678');

-- Table 8: Mall(mid, chainid, address, numShops)
INSERT INTO Mall VALUES
('M000000001', 'C000000001', '123456', 10),
('M000000002', 'C000000002', '456789', 20),
('M000000003', 'C000000003', '789012', 30),
('M000000004', 'C000000004', '012345', 40),
('M000000005', 'C000000005', '345678', 50);

-- Table 3: Shop(sid, mid, type)
INSERT INTO Shop VALUES
('S000000001', 'M000000001', 'clothing'),
('S000000002', 'M000000002', 'food'),
('S000000003', 'M000000003', 'electronics'),
('S000000004', 'M000000004', 'clothing'),
('S000000005', 'M000000005', 'food'),
('S000000006', 'M000000001', 'electronics');

-- Table 4: ShopRecord(sid, uid, amountSpent, datetimeIn, datetimeOut)
INSERT INTO ShopRecord VALUES 
('S000000003', 'U000000001', 100.00, '2021-01-01', '2021-01-01'),
('S000000003', 'U000000002', 200.00, '2021-01-01', '2021-01-01'),
('S000000003', 'U000000003', 300.00, '2021-01-01', '2021-01-01'),
('S000000001', 'U000000004', 400.00, '2023-12-02', '2023-12-02'),
('S000000001', 'U000000006', 400.00, '2023-12-02', '2023-12-02'),
('S000000001', 'U000000005', 500.00, '2023-12-02', '2023-12-02'),
('S000000002', 'U000000005', 500.00, '2023-12-02', '2023-12-02'),
('S000000003', 'U000000005', 500.00, '2023-12-03', '2023-12-03'),
('S000000004', 'U000000005', 500.00, '2023-12-04', '2023-12-04'),
('S000000005', 'U000000005', 500.00, '2023-12-04', '2023-12-04'),
('S000000006', 'U000000005', 500.00, '2023-12-05', '2023-12-05'),
('S000000001', 'U000000005', 499.99, '2023-12-06', '2023-12-06'),
('S000000006', 'U000000005', 500.00, '2023-12-07', '2023-12-07'),
('S000000001', 'U000000005', 250.00, '2023-12-08', '2023-12-08'),
('S000000006', 'U000000005', 500.00, '2023-12-09', '2023-12-09'),
('S000000002', 'U000000003', 199.00, '2023-12-09', '2023-12-09'),
('S000000002', 'U000000003', 199.00, '2023-12-10', '2023-12-10'),
('S000000002', 'U000000003', 199.00, '2023-12-11', '2023-12-11'),
('S000000002', 'U000000003', 199.00, '2023-12-12', '2023-12-12'),
('S000000002', 'U000000003', 199.00, '2023-12-13', '2023-12-13'),
('S000000002', 'U000000003', 199.00, '2023-12-14', '2023-12-14'),
('S000000002', 'U000000003', 199.00, '2023-12-15', '2023-12-15'),
('S000000002', 'U000000003', 199.00, '2023-12-16', '2023-12-16'),
('S000000002', 'U000000007', 199.00, '2023-12-15', '2023-12-15'),
('S000000002', 'U000000008', 199.00, '2023-12-15', '2023-12-15'),
('S000000003', 'U000000009', 299.00, '2023-12-16', '2023-12-16'),
('S000000003', 'U000000010', 299.00, '2023-12-16', '2023-12-16');

-- Table 6: RestaurantChain(rid, address)
INSERT INTO RestaurantChain VALUES
('R000000001', '123456'),
('R000000002', '456789'),
('R000000003', '789012'),
('R000000004', '012345'),
('R000000005', '345678');

-- Table 5: RestaurantOutlet(oid, rid, mid)
INSERT INTO RestaurantOutlet VALUES
('O000000001', 'R000000001', 'M000000001'),
('O000000002', 'R000000002', 'M000000002'),
('O000000003', 'R000000003', 'M000000003'),
('O000000004', 'R000000004', 'M000000004'),
('O000000005', 'R000000005', 'M000000005');



-- Table 7: DineRecord(oid, uid, amountSpent, datetimeIn, datetimeOut)
INSERT INTO DineRecord VALUES
('O000000001', 'U000000001', 100.00, '2021-01-01', '2021-01-01'),
('O000000001', 'U000000001', 100.00, '2021-02-02', '2021-02-02'),
('O000000001', 'U000000002', 200.00, '2021-02-02', '2021-02-02'),
('O000000001', 'U000000003', 200.00, '2021-02-02', '2021-02-02'),
('O000000005', 'U000000001', 100.00, '2021-03-03', '2021-03-03'),
('O000000005', 'U000000002', 200.00, '2021-03-03', '2021-03-03'),
('O000000005', 'U000000003', 200.00, '2021-03-03', '2021-03-03'),
('O000000004', 'U000000001', 100.00, '2021-04-04', '2021-04-04'),
('O000000004', 'U000000002', 200.00, '2021-04-04', '2021-04-04'),
('O000000004', 'U000000003', 200.00, '2021-04-04', '2021-04-04'),
('O000000002', 'U000000002', 200.00, '2021-02-02', '2021-02-02'),
('O000000003', 'U000000003', 300.00, '2021-03-03', '2021-03-03'),
('O000000004', 'U000000004', 400.00, '2021-04-04', '2021-04-04'),
('O000000005', 'U000000005', 500.00, '2021-05-05', '2021-05-05'),
('O000000002', 'U000000001', 100.00, '2021-01-01', '2021-01-01'),
('O000000003', 'U000000001', 100.00, '2021-01-01', '2021-01-01'),
('O000000004', 'U000000001', 100.00, '2021-01-01', '2021-01-01'),
('O000000005', 'U000000001', 100.00, '2021-01-01', '2021-01-01');





-- Table 10: Complaint(cid, uid, text, status, datetimeFiled, complaintQNo)
INSERT INTO Complaint VALUES
('C000000001', 'U000000001', 'Complaint 1', 'pending', '2021-01-01', 1),
('C000000002', 'U000000002', 'Complaint 2', 'being handled', '2021-02-02', 2),
('C000000003', 'U000000003', 'Complaint 3', 'addressed', '2021-03-03', 3),
('C000000004', 'U000000004', 'Complaint 4', 'pending', '2021-04-04', 4),
('C000000005', 'U000000005', 'Complaint 5', 'being handled', '2021-05-05', 5);

-- Table 11: Shop Complaint
-- 11A: ShopComplaint(cid, uid, sid, text, status, datetimeFiled)
INSERT INTO ShopComplaint VALUES
('C000000001', 'U000000001', 'S000000001', 'Complaint 1', 'pending', '2023-12-01'),
('C000000002', 'U000000002', 'S000000002', 'Complaint 2', 'being handled', '2023-12-02'),
('C000000003', 'U000000003', 'S000000003', 'Complaint 3', 'addressed', '2023-12-03'),
('C000000004', 'U000000004', 'S000000004', 'Complaint 4', 'pending', '2023-12-04'),
('C000000005', 'U000000005', 'S000000005', 'Complaint 5', 'being handled', '2023-12-05'),
('C000000006', 'U000000004', 'S000000001', 'Complaint 6', 'pending', '2023-12-04'),
('C000000007', 'U000000005', 'S000000005', 'Complaint 7', 'being handled', '2023-12-05'),
('C000000008', 'U000000004', 'S000000001', 'Complaint 8', 'pending', '2023-12-04'),
('C000000009', 'U000000005', 'S000000005', 'Complaint 9', 'being handled', '2023-12-05'),
('C000000010', 'U000000004', 'S000000001', 'Complaint 10', 'pending', '2023-12-04'),
('C000000011', 'U000000004', 'S000000001', 'Complaint 11', 'pending', '2023-12-04');

-- 11B: ShopComplaintQueue(sid, complaintQNo)
INSERT INTO ShopComplaintQueue VALUES
('S000000001', 1),
('S000000002', 2),
('S000000003', 3),
('S000000004', 4),
('S000000005', 5);

-- Table 12: Restaurant Complaint
-- 12A: RestaurantComplaint(cid, uid, oid, text, status, datetimeFiled)
INSERT INTO RestaurantComplaint VALUES
('C000000001', 'U000000001', 'O000000001', 'Complaint 1', 'pending', '2021-01-01'),
('C000000002', 'U000000002', 'O000000002', 'Complaint 2', 'being handled', '2021-02-02'),
('C000000003', 'U000000003', 'O000000003', 'Complaint 3', 'addressed', '2021-03-03'),
('C000000004', 'U000000004', 'O000000004', 'Complaint 4', 'pending', '2021-04-04'),
('C000000005', 'U000000005', 'O000000005', 'Complaint 5', 'being handled', '2021-05-05');

-- 12B: RestaurantComplaintQueue(oid, complaintQNo)
INSERT INTO RestaurantComplaintQueue VALUES
('O000000001', 1),
('O000000002', 2),
('O000000003', 3),
('O000000004', 4),
('O000000005', 5);

-- Table 13: Voucher(vid, status, description, dateIssued, dateExpire)
INSERT INTO Voucher VALUES
('V000000001', 'allocated', 'Voucher 1', '2021-01-01', '2021-01-01'),
('V000000002', 'redeemed', 'Voucher 2', '2021-02-02', '2021-02-02'),
('V000000003', 'expired', 'Voucher 3', '2021-03-03', '2021-03-03'),
('V000000004', 'allocated', 'Voucher 4', '2021-04-04', '2021-04-04'),
('V000000005', 'redeemed', 'Voucher 5', '2021-05-05', '2021-05-05');

-- Table 14: Purchase Voucher
-- 14A: PurchaseVoucher(vid, description, dateIssued, dateExpire uid, purchaseDiscount, datetimeUsed)
INSERT INTO PurchaseVoucher VALUES
('PuV0000001', 'Voucher 1', '2021-01-01', '2021-01-01', 'U000000001', 0.1, '2021-01-01'),
('PuV0000002', 'Voucher 2', '2021-02-02', '2021-02-02', 'U000000002', 0.2, '2021-02-02'),
('PuV0000003', 'Voucher 3', '2021-03-03', '2021-03-03', 'U000000003', 0.3, '2021-03-03'),
('PuV0000004', 'Voucher 4', '2021-04-04', '2021-04-04', 'U000000004', 0.4, '2021-04-04'),
('PuV0000005', 'Voucher 5', '2021-05-05', '2021-05-05', 'U000000005', 0.5, '2021-05-05');

-- 14B: PurchaseVoucherStatus(dateIssued, dateExpire, datetimeUsed, status)
INSERT INTO PurchaseVoucherStatus VALUES
('2021-01-01', '2021-01-01', '2021-01-01', 'allocated'),
('2021-02-02', '2021-02-02', '2021-02-02', 'redeemed'),
('2021-03-03', '2021-03-03', '2021-03-03', 'expired'),
('2021-04-04', '2021-04-04', '2021-04-04', 'allocated'),
('2021-05-05', '2021-05-05', '2021-05-05', 'redeemed');

-- Table 15: Dine Voucher
-- 15A: DineVoucher(vid, description, dateIssued, dateExpire uid, cashDiscount, datetimeUsed)
INSERT INTO DineVoucher VALUES
('DV00000001', 'Voucher 1', '2021-01-01', '2021-01-01', 'U000000001', 100.00, '2021-01-01'),
('DV00000002', 'Voucher 2', '2021-02-02', '2021-02-02', 'U000000002', 200.00, '2021-02-02'),
('DV00000003', 'Voucher 3', '2021-03-03', '2021-03-03', 'U000000003', 300.00, '2021-03-03'),
('DV00000004', 'Voucher 4', '2021-04-04', '2021-04-04', 'U000000004', 400.00, '2021-04-04'),
('DV00000005', 'Voucher 5', '2021-05-05', '2021-05-05', 'U000000005', 500.00, '2021-05-05');

-- 15B: DineVoucherStatus(dateIssued, dateExpire, datetimeUsed, status)
INSERT INTO DineVoucherStatus VALUES
('2021-01-01', '2021-01-01', '2021-01-01', 'allocated'),
('2021-02-02', '2021-02-02', '2021-02-02', 'redeemed'),
('2021-03-03', '2021-03-03', '2021-03-03', 'expired'),
('2021-04-04', '2021-04-04', '2021-04-04', 'allocated'),
('2021-05-05', '2021-05-05', '2021-05-05', 'redeemed');

-- Table 16: Group Voucher
-- 16A: GroupVoucher(vid, description, dateIssued, dateExpire uid, cashDiscount, datetimeUsed)
INSERT INTO GroupVoucher 
VALUES
('GV00000001', 'Voucher 1', '2021-01-01', '2021-01-01', 'U000000001', 100.00, '2021-01-01'),
('GV00000002', 'Voucher 2', '2021-02-02', '2021-02-02', 'U000000002', 200.00, '2021-02-02'),
('GV00000003', 'Voucher 3', '2021-03-03', '2021-03-03', 'U000000003', 300.00, '2021-03-03'),
('GV00000004', 'Voucher 4', '2021-04-04', '2021-04-04', 'U000000004', 400.00, '2021-04-04'),
('GV00000005', 'Voucher 5', '2021-05-05', '2021-05-05', 'U000000005', 500.00, '2021-05-05');

-- 16B: GroupVoucherStatus(dateIssued, dateExpire, datetimeUsed, status)
INSERT INTO GroupVoucherStatus VALUES
('2021-01-01', '2021-01-01', '2021-01-01', 'allocated'),
('2021-02-02', '2021-02-02', '2021-02-02', 'redeemed'),
('2021-03-03', '2021-03-03', '2021-03-03', 'expired'),
('2021-04-04', '2021-04-04', '2021-04-04', 'allocated'),
('2021-05-05', '2021-05-05', '2021-05-05', 'redeemed');

-- Table 17: PackageVoucher(vid, status, description, dateIssued, dateExpire, packageDiscount)
INSERT INTO PackageVoucher VALUES
('PaV0000001', 'allocated', 'Voucher 1', '2021-01-01', '2021-01-01', 100.00),
('PaV0000002', 'redeemed', 'Voucher 2', '2021-02-02', '2021-02-02', 200.00),
('PaV0000003', 'expired', 'Voucher 3', '2021-03-03', '2021-03-03', 300.00),
('PaV0000004', 'allocated', 'Voucher 4', '2021-04-04', '2021-04-04', 400.00),
('PaV0000005', 'redeemed', 'Voucher 5', '2021-05-05', '2021-05-05', 500.00);


-- Table 18: DayPackage(did, vid, uid, description)
INSERT INTO DayPackage VALUES
('D000000001', 'PaV0000001', 'U000000001', 'Day Package 1'),
('D000000001', 'PaV0000001', 'U000000002', 'Day Package 1'),
('D000000001', 'PaV0000001', 'U000000003', 'Day Package 1'),
('D000000001', 'PaV0000001', 'U000000008', 'Day Package 1'),
('D000000002', 'PaV0000002', 'U000000004', 'Day Package 2'),
('D000000002', 'PaV0000002', 'U000000005', 'Day Package 2'),
('D000000003', 'PaV0000002', 'U000000005', 'Day Package 3'),
('D000000004', 'PaV0000002', 'U000000005', 'Day Package 4'),
('D000000004', 'PaV0000002', 'U000000001', 'Day Package 4'),
('D000000005', 'PaV0000002', 'U000000005', 'Day Package 5'),
('D000000002', 'PaV0000002', 'U000000001', 'Day Package 2'),
('D000000003', 'PaV0000002', 'U000000001', 'Day Package 3'),
('D000000005', 'PaV0000002', 'U000000001', 'Day Package 5');

-- Table 19: MallPackage(mid, did)
INSERT INTO MallPackage VALUES
('M000000001', 'D000000001', 'U000000001'),
('M000000001', 'D000000002', 'U000000001'),
('M000000001', 'D000000003', 'U000000001'),
('M000000001', 'D000000004', 'U000000001'),
('M000000001', 'D000000005', 'U000000001'),
('M000000002', 'D000000001', 'U000000001'),
('M000000002', 'D000000002', 'U000000001'),
('M000000003', 'D000000001', 'U000000001'),
('M000000004', 'D000000001', 'U000000001'),
('M000000005', 'D000000001', 'U000000001');

-- Table 20: RestaurantOutletPackage(oid, did)
INSERT INTO RestaurantOutletPackage VALUES
('O000000001', 'D000000001', 'U000000001'),
('O000000002', 'D000000002', 'U000000001'),
('O000000003', 'D000000003', 'U000000001'),
('O000000004', 'D000000004', 'U000000001'),
('O000000005', 'D000000005', 'U000000001');

-- Table 21: Recommendation
-- 21A: Recommendation(nid, did, validPeriod, dateIssued)
INSERT INTO Recommendation VALUES
('N000000001', 'D000000001', 100, '2021-01-01', 'U000000001'),
('N000000002', 'D000000002', 200, '2021-02-02', 'U000000001'),
('N000000003', 'D000000003', 300, '2021-03-03', 'U000000001'),
('N000000004', 'D000000004', 400, '2021-04-04', 'U000000001'),
('N000000005', 'D000000005', 500, '2021-05-05', 'U000000001');

-- 21B: ReccMallVouchers(purchase_vid, mid)
INSERT INTO ReccMallVouchers VALUES
('PuV0000001', 'M000000001'),
('PuV0000002', 'M000000002'),
('PuV0000003', 'M000000003'),
('PuV0000004', 'M000000004'),
('PuV0000005', 'M000000005');

-- 21C: ReccRestaurantVouchers(dine_vid, oid)
INSERT INTO ReccRestaurantVouchers VALUES
('DV00000001', 'O000000001', 'D000000001', 'M000000001'),
('DV00000002', 'O000000002', 'D000000001', 'M000000001'),
('DV00000003', 'O000000003', 'D000000001', 'M000000001'),
('DV00000004', 'O000000004', 'D000000001', 'M000000001'),
('DV00000005', 'O000000005', 'D000000001', 'M000000001');

-- 21D: ReccPackageVouchers(purchase_vid, dine_vid, did)
INSERT INTO ReccPackageVouchers VALUES
('PuV0000001', 'DV00000001', 'D000000001', 'U000000001'),
('PuV0000002', 'DV00000002', 'D000000002', 'U000000001'),
('PuV0000003', 'DV00000003', 'D000000003', 'U000000001'),
('PuV0000004', 'DV00000004', 'D000000004', 'U000000001'),
('PuV0000005', 'DV00000005', 'D000000005', 'U000000001');

-- Table 22: UserAccountRecommendation(uid, nid)
INSERT INTO UserAccountRecommendation VALUES
('U000000001', 'N000000001'),
('U000000002', 'N000000002'),
('U000000003', 'N000000003'),
('U000000004', 'N000000004'),
('U000000005', 'N000000005');


