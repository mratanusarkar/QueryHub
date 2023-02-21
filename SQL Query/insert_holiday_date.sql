/*
 * Author: Atanu Sarkar
 * Last Edited: 21-01-2022
 * Last Version: v1.0.0
 *
 * MSSQL Script to insert holidays into DB
 * 
 * For missing or new holidays, Enter the below details and run the script:
 * @StartDate:      the start date of the missing holidays
 * @EndDate:        the end date till which the holidays need to be inserted
 * @HolidayReason:  the reason for holiday, eg: Saturday/Sunday
 *
 * Here, the table name is holiday. replace it with your column name.
 * and an example is shown for "Sunday"
 *
 */


DECLARE @MyCursor CURSOR;
DECLARE @OriginId NVARCHAR(255);
DECLARE @HolidayReason NVARCHAR(255);
DECLARE @HolidayDay NVARCHAR(255);

DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME
DECLARE @CurrentDate AS DATETIME

-- Input your holiday details:
SET @HolidayDay = 'Sunday'      /* enter what date you want to insert holiday (options: 'Monday', 'Tuesday', and so on...) */
SET @HolidayReason = 'Sunday'   /* enter the reason you want to insert in the DB or reflect in your calendar implementation */
SET @StartDate = '2022-01-01'
SET @EndDate = '2023-12-31'
SET @CurrentDate = @StartDate

BEGIN
    SET @MyCursor = CURSOR FOR
    SELECT DISTINCT originId FROM holidays /* this may come from any other table too! */    

    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @OriginId

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- @OriginId: can be a state, region, country, organization, or any entity to which the calander implementation belongs to
        -- you can remove this section if you dont have it in your implementation

        /* YOUR ALGORITHM GOES HERE */
        SET @CurrentDate = @StartDate
        WHILE (@CurrentDate < @EndDate)
        BEGIN
            IF DATENAME(WEEKDAY, @CurrentDate) IN (@HolidayDay) /* enter what date you want to insert holiday */

                /* insert a new row query here */
                PRINT CONVERT(varchar, @CurrentDate, 23)

                -----------------------------------------------
                ---------- UNCOMMENT BELOW TO INSERT ----------
                -----------------------------------------------
                INSERT INTO holidays (
                    OriginId,
                    HolidayDate,
                    HolidayReason,
                    CreatedAt,
                    UpdatedAt
                )
                VALUES (
                    @OriginId,
                    CONVERT(varchar, @CurrentDate, 23),
                    @HolidayReason,
                    GETDATE(),
                    GETDATE()
                )
                -----------------------------------------------
                ----------- END OF INSERT STATEMENT -----------
                -----------------------------------------------

            SET @CurrentDate = CONVERT(varchar, DATEADD(day, 1, @CurrentDate), 101); /* increment current date */
        END

        /* END OF ALGORITHM */
        FETCH NEXT FROM @MyCursor 
        INTO @OriginId 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;
