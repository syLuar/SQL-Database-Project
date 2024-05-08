--- Based on create.sql and insert.sql
--- Act 4: Required Queries

-- Question 1: 
-- Find the most popular day packages where all participants are related to one another as either family members or members of the same club.
SELECT D.did, D.description, COUNT(DISTINCT U.uid) AS numParticipants
FROM DayPackage D
JOIN UserAccount U ON D.uid = U.uid
JOIN Related R ON (U.uid = R.uid1 OR U.uid = R.uid2)
WHERE R.type IN ('family', 'club')
GROUP BY D.did, D.description
HAVING COUNT(DISTINCT U.uid) >= 1
ORDER BY numParticipants DESC;



-- Question 2:
-- Find families who frequently shopped and dined together, with or without day packages. As part of your output, indicate whether these families use day packages or not. “frequently” means at least 50% of the time.

WITH CombinedActivities AS (
    -- Aggregate all dining and shopping activities
    SELECT uid, oid AS LocationID, datetimeIn, 'Dine' AS ActivityType
    FROM DineRecord
    UNION ALL
    SELECT uid, sid AS LocationID, datetimeIn, 'Shop' AS ActivityType
    FROM ShopRecord
),
FamilyMembers AS (
    -- Identify pairs of family members based on shared addresses
    SELECT a.uid AS UserAccountID, b.uid AS FamilyMemberID, a.address
    FROM UserAccount a
    JOIN UserAccount b ON a.address = b.address AND a.uid <> b.uid
),
FamilyActivities AS (
    -- Count family activities by checking for shared activities between family member pairs
    SELECT 
        ca.uid, 
        COUNT(DISTINCT ca.datetimeIn) AS FamilyActivitiesCount
    FROM CombinedActivities ca
    JOIN FamilyMembers fm ON ca.uid = fm.UserAccountID
    JOIN CombinedActivities ca2 ON ca.LocationID = ca2.LocationID 
                                AND ca.datetimeIn = ca2.datetimeIn 
                                AND ca2.uid = fm.FamilyMemberID
    GROUP BY ca.uid
),
TotalActivities AS (
    -- Calculate the total number of activities for each UserAccount
    SELECT uid, COUNT(*) AS TotalActivitiesCount
    FROM CombinedActivities
    GROUP BY uid
),
ActivityRatios AS (
    -- Calculate the ratio of family activities to total activities for each UserAccount
    SELECT 
        ta.uid, 
        COALESCE(fa.FamilyActivitiesCount, 0) AS FamilyActivities,
        ta.TotalActivitiesCount,
        CASE 
            WHEN ta.TotalActivitiesCount > 0 THEN COALESCE(fa.FamilyActivitiesCount, 0) * 1.0 / ta.TotalActivitiesCount
            ELSE 0 
        END AS FamilyActivityRatio
    FROM TotalActivities ta
    LEFT JOIN FamilyActivities fa ON ta.uid = fa.uid
),
ActivityRatiosWithAddress AS (
    -- Add address information to the activity ratios for grouping by families
    SELECT 
        AR.uid, 
        U.address, 
        AR.FamilyActivities,
        AR.TotalActivitiesCount,
        AR.FamilyActivityRatio
    FROM ActivityRatios AR
    JOIN UserAccount U ON AR.uid = U.uid
),
FamilyDayPackageUsage AS (
    -- Check for day package usage by any family member
    SELECT 
        U.address,
        MAX(CASE WHEN DP.vid IS NOT NULL THEN 1 ELSE 0 END) AS UsesDayPackage
    FROM UserAccount U
    LEFT JOIN DayPackage DP ON U.uid = DP.uid
    GROUP BY U.address
),
FamilyAverageRatios AS (
    -- Calculate the average family activity ratio for each family group, defined by address
    SELECT 
        ARA.address, 
        AVG(ARA.FamilyActivityRatio) AS AvgFamilyActivityRatio,
        SUM(ARA.FamilyActivities) AS TotalFamilyActivities,
        SUM(ARA.TotalActivitiesCount) AS TotalActivities,
        CASE WHEN FDP.UsesDayPackage = 1 THEN 'Yes' ELSE 'No' END AS UsesDayPackages
    FROM ActivityRatiosWithAddress ARA
    JOIN FamilyDayPackageUsage FDP ON ARA.address = FDP.address
    GROUP BY ARA.address, FDP.UsesDayPackage
)
SELECT 
    address AS FamilyAddress, 
    AvgFamilyActivityRatio AS AvgFamilyActivityFreq, 
    UsesDayPackages -- Indicate whether each family uses day packages or not
FROM FamilyAverageRatios
WHERE AvgFamilyActivityRatio >= 0.5 -- Filter out families that have at least 0.5 AvgFamilyActivityRatio
ORDER BY AvgFamilyActivityRatio DESC;



-- Question 3:
-- What are the most popular recommendations from the app regarding malls?
SELECT M.mid, M.chainid, M.address, COUNT(*) AS numRecommendations
FROM Mall M, MallPackage MP, Recommendation R
WHERE M.mid = MP.mid AND MP.did = R.did
GROUP BY M.mid, M.chainid, M.address
ORDER BY numRecommendations DESC;


-- Question 4:
-- Compulsive shoppers are those who have visited a certain mall more than 5 times within a certain period of time. Find the youngest compulsive shoppers and the amount they spent in total during December 2023.
SELECT U.uid, U.name, U.DoB, M.mid, COUNT(*) AS numVisits, SUM(SR.amountSpent) AS totalAmountSpent
FROM UserAccount U
JOIN ShopRecord SR ON U.uid = SR.uid
JOIN Shop S ON SR.sid = S.sid
JOIN Mall M ON S.mid = M.mid
WHERE SR.datetimeIn BETWEEN '2023-12-01' AND '2023-12-31'
GROUP BY U.uid, U.name, U.DoB, M.mid
HAVING COUNT(*) > 5
ORDER BY U.DoB DESC;

-- Question 5:
-- Find UserAccounts who have dined in all the restaurants in some malls, but have never dined in any restaurants in some other malls.
SELECT U.uid, U.name
FROM UserAccount U
WHERE EXISTS (
    -- Malls where the UserAccount has dined in all restaurants
    SELECT 1
    FROM Mall M
    WHERE NOT EXISTS (
        -- Restaurants in the mall where the UserAccount has not dined
        SELECT 1
        FROM RestaurantOutlet RO
        WHERE RO.mid = M.mid
        AND NOT EXISTS (
            SELECT 1
            FROM DineRecord DR
            WHERE DR.oid = RO.oid
            AND DR.uid = U.uid
        )
    )
) AND EXISTS (
    -- Malls where the UserAccount has not dined in any restaurant
    SELECT 1
    FROM Mall M
    WHERE NOT EXISTS (
        -- Restaurants in the mall where the UserAccount has dined
        SELECT 1
        FROM RestaurantOutlet RO
        WHERE RO.mid = M.mid
        AND EXISTS (
            SELECT 1
            FROM DineRecord DR
            WHERE DR.oid = RO.oid
            AND DR.uid = U.uid
        )
    )
);

-- Question 6:
-- What are the top 3 highest earning malls and restaurants?
WITH CombinedRevenue AS (
    -- Combine shop and restaurant revenues
    SELECT M.mid, SR.amountSpent AS Revenue
    FROM Mall M
    JOIN Shop S ON M.mid = S.mid
    JOIN ShopRecord SR ON S.sid = SR.sid
    UNION ALL
    SELECT M.mid, DR.amountSpent AS Revenue
    FROM Mall M
    JOIN RestaurantOutlet RO ON M.mid = RO.mid
    JOIN DineRecord DR ON RO.oid = DR.oid
)
SELECT mid, SUM(Revenue) AS TotalRevenue
FROM CombinedRevenue
GROUP BY mid
ORDER BY TotalRevenue DESC
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY;

SELECT O.oid, SUM(DR.amountSpent) AS totalAmountSpent
FROM RestaurantOutlet O
JOIN DineRecord DR ON O.oid = DR.oid
GROUP BY O.oid
ORDER BY totalAmountSpent DESC
OFFSET 0 ROWS FETCH FIRST 3 ROWS
ONLY;

-- Question 7:
-- Find shops that received the most complaints in December 2023
SELECT S.sid, COUNT(*) AS numComplaints
FROM Shop S
JOIN ShopComplaint SC ON S.sid = SC.sid
WHERE SC.datetimeFiled BETWEEN '2023-12-01' AND '2023-12-31'
GROUP BY S.sid
ORDER BY numComplaints DESC
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY;