USE [US_Accidents_DW];
GO

IF OBJECT_ID('[dbo].[FACT_ACCIDENT]', 'U') IS NOT NULL DROP TABLE [dbo].[FACT_ACCIDENT];
IF OBJECT_ID('[dbo].[DIM_WEATHER]', 'U') IS NOT NULL DROP TABLE [dbo].[DIM_WEATHER];
IF OBJECT_ID('[dbo].[DIM_SEVERITY]', 'U') IS NOT NULL DROP TABLE [dbo].[DIM_SEVERITY];
IF OBJECT_ID('[dbo].[DIM_TRAFFIC_SIGNAL]', 'U') IS NOT NULL DROP TABLE [dbo].[DIM_TRAFFIC_SIGNAL];
IF OBJECT_ID('[dbo].[DIM_ROAD_STRUCTURE]', 'U') IS NOT NULL DROP TABLE [dbo].[DIM_ROAD_STRUCTURE];
IF OBJECT_ID('[dbo].[DIM_LOCATION]', 'U') IS NOT NULL DROP TABLE [dbo].[DIM_LOCATION];
IF OBJECT_ID('[dbo].[DIM_TIME]', 'U') IS NOT NULL DROP TABLE [dbo].[DIM_TIME];
IF OBJECT_ID('[dbo].[DIM_DATE]', 'U') IS NOT NULL DROP TABLE [dbo].[DIM_DATE];
GO

SELECT * FROM [dbo].[DIM_DATE];
SELECT * FROM [dbo].[DIM_TIME]; 
SELECT * FROM [dbo].[DIM_LOCATION];
SELECT * FROM [dbo].[DIM_ROAD_STRUCTURE];
SELECT * FROM [dbo].[DIM_TRAFFIC_SIGNAL];
SELECT * FROM [dbo].[DIM_SEVERITY];
SELECT * FROM [dbo].[DIM_WEATHER];
SELECT * FROM [dbo].[FACT_ACCIDENT];
GO

-- =========================================================
-- 1. BẢNG CHIỀU NGÀY ([DIM_DATE])
-- =========================================================
CREATE TABLE [dbo].[DIM_DATE] (
    [ID_DATE] INT NOT NULL PRIMARY KEY,  -- Dạng YYYYMMDD (VD: 20210131)
    [FULL_DATE] DATE NOT NULL,
    [DAY] INT NOT NULL,
    [MONTH] INT NOT NULL,
    [QUARTER] INT NOT NULL,
    [YEAR] INT NOT NULL,
    [DAY_OF_WEEK] INT NOT NULL,          -- 1: Chủ Nhật → 7: Thứ Bảy
    [IS_WEEKEND] BIT NOT NULL DEFAULT 0  -- 0: Ngày thường, 1: Cuối tuần
);
GO

SELECT * FROM [dbo].[DIM_DATE];
TRUNCATE TABLE [dbo].[DIM_DATE];
GO

-- =========================================================
-- 2. BẢNG CHIỀU THỜI GIỜ ([DIM_TIME])
-- =========================================================
CREATE TABLE [dbo].[DIM_TIME] (
    [ID_TIME] INT NOT NULL PRIMARY KEY,  -- Dạng HHMMSS (VD: 143015)
    [FULL_TIME] TIME(0) NOT NULL,
    [HOUR] INT NOT NULL,
    [MINUTE] INT NOT NULL,
    [SECOND] INT NOT NULL
);
GO

SELECT * FROM [dbo].[DIM_TIME];
TRUNCATE TABLE [dbo].[DIM_TIME];
GO

-- =========================================================
-- 3. BẢNG CHIỀU VỊ TRÍ ([DIM_LOCATION])
-- =========================================================
CREATE TABLE [dbo].[DIM_LOCATION] (
    [ID_LOCATION] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [STREET] NVARCHAR(255) NULL,    -- Tên con đường nơi xảy ra tai nạn
    [CITY] NVARCHAR(100) NULL,      -- Tên thành phố
    [COUNTY] NVARCHAR(100) NULL,    -- Tên quận / hạt
    [STATE] NVARCHAR(10) NULL,      -- Tên tiểu bang (CA, TX, FL, NY...)
    [TIMEZONE] NVARCHAR(50) NULL    -- Múi giờ địa phương (US/Eastern, US/Pacific...)
);
GO

SELECT * FROM [dbo].[DIM_LOCATION];
TRUNCATE TABLE [dbo].[DIM_LOCATION];
GO

-- =========================================================
-- 4. BẢNG CHIỀU CẤU TRÚC ĐƯỜNG ([DIM_ROAD_STRUCTURE])
-- =========================================================
CREATE TABLE [dbo].[DIM_ROAD_STRUCTURE] (
    [ID_ROAD_STRUCTURE] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [AMENITY] BIT NOT NULL DEFAULT 0,        -- Có tiện ích công cộng (trạm dừng nghỉ, công viên)
    [BUMP] BIT NOT NULL DEFAULT 0,           -- Có gờ giảm tốc
    [JUNCTION] BIT NOT NULL DEFAULT 0,       -- Thuộc nút giao thông / ngã ba / ngã tư
    [NO_EXIT] BIT NOT NULL DEFAULT 0,        -- Đường cụt
    [RAILWAY] BIT NOT NULL DEFAULT 0,        -- Có đường ray xe lửa
    [ROUNDABOUT] BIT NOT NULL DEFAULT 0,     -- Thuộc vòng xoay / bùng binh
    [STATION] BIT NOT NULL DEFAULT 0         -- Có trạm xe buýt / trạm trung chuyển
);
GO

SELECT * FROM [dbo].[DIM_ROAD_STRUCTURE];
TRUNCATE TABLE [dbo].[DIM_ROAD_STRUCTURE];
GO

-- =========================================================
-- 5. BẢNG CHIỀU TÍN HIỆU GIAO THÔNG ([DIM_TRAFFIC_SIGNAL])
-- =========================================================
CREATE TABLE [dbo].[DIM_TRAFFIC_SIGNAL] (
    [ID_TRAFFIC_SIGNAL] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CROSSING] BIT NOT NULL DEFAULT 0,         -- Có vạch kẻ đường cho người đi bộ
    [GIVE_WAY] BIT NOT NULL DEFAULT 0,         -- Có biển báo nhường đường
    [STOP_SIGN] BIT NOT NULL DEFAULT 0,        -- Có biển báo dừng lại (STOP)
    [TRAFFIC_CALMING] BIT NOT NULL DEFAULT 0,  -- Có thiết bị cưỡng chế giảm tốc độ
    [TRAFFIC_SIGNAL] BIT NOT NULL DEFAULT 0    -- Có hệ thống đèn tín hiệu giao thông
);
GO

SELECT * FROM [dbo].[DIM_TRAFFIC_SIGNAL];
TRUNCATE TABLE [dbo].[DIM_TRAFFIC_SIGNAL];
GO

-- =========================================================
-- 6. BẢNG CHIỀU MỨC ĐỘ NGHIÊM TRỌNG ([DIM_SEVERITY])
-- =========================================================
CREATE TABLE [dbo].[DIM_SEVERITY] (
    [ID_SEVERITY] INT NOT NULL PRIMARY KEY,    -- Mức 1, 2, 3, 4
    [SEVERITY_DESC] NVARCHAR(100) NOT NULL     -- Diễn giải mô tả mức độ
);
GO

SELECT * FROM [dbo].[DIM_SEVERITY];
TRUNCATE TABLE [dbo].[DIM_SEVERITY];
GO

-- =========================================================
-- 7. BẢNG CHIỀU THỜI TIẾT ([DIM_WEATHER])
-- =========================================================
CREATE TABLE [dbo].[DIM_WEATHER] (
    [ID_WEATHER] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [WEATHER_CONDITION] NVARCHAR(100) NULL,    -- Điều kiện thời tiết (Fair, Rain, Snow, Fog...)
    [WIND_DIRECTION] NVARCHAR(50) NULL         -- Hướng gió (CALM, NW, SW, NE, SE, N, S, E, W...)
);
GO

SELECT * FROM [dbo].[DIM_WEATHER];
TRUNCATE TABLE [dbo].[DIM_WEATHER];
GO

-- =========================================================
-- 8. BẢNG SỰ KIỆN TAI NẠN ([FACT_ACCIDENT])
-- =========================================================
CREATE TABLE [dbo].[FACT_ACCIDENT] (
    [ID_FACT] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ACCIDENT_ID] NVARCHAR(50) NOT NULL,         -- Mã vụ tai nạn gốc (VD: A-2047758)

    -- 9 Khóa Ngoại trỏ đến 7 Bảng Chiều
    [ID_START_DATE] INT NOT NULL,                -- FK → DIM_DATE: Ngày bắt đầu tai nạn
    [ID_START_TIME] INT NOT NULL,                -- FK → DIM_TIME: Giờ bắt đầu tai nạn
    [ID_END_DATE] INT NOT NULL,                  -- FK → DIM_DATE: Ngày kết thúc tai nạn
    [ID_END_TIME] INT NOT NULL,                  -- FK → DIM_TIME: Giờ kết thúc tai nạn
    [ID_LOCATION] INT NOT NULL,                  -- FK → DIM_LOCATION
    [ID_ROAD_STRUCTURE] INT NOT NULL,            -- FK → DIM_ROAD_STRUCTURE
    [ID_TRAFFIC_SIGNAL] INT NOT NULL,            -- FK → DIM_TRAFFIC_SIGNAL
    [ID_SEVERITY] INT NOT NULL,                  -- FK → DIM_SEVERITY
    [ID_WEATHER] INT NOT NULL,                   -- FK → DIM_WEATHER
    
    -- Các Chỉ số Đo lường (Measures)
    [DISTANCE] FLOAT NULL,                       -- Chiều dài đoạn đường bị ảnh hưởng (dặm)
    [TEMPERATURE] FLOAT NULL,                    -- Nhiệt độ không khí (°F)
    [HUMIDITY] FLOAT NULL,                       -- Độ ẩm tương đối (%)
    [PRESSURE] FLOAT NULL,                       -- Áp suất khí quyển (inch Hg)
    [VISIBILITY] FLOAT NULL,                     -- Tầm nhìn xa (dặm)
    [WIND_SPEED] FLOAT NULL,                     -- Tốc độ gió (mph)
    [PRECIPITATION] FLOAT NULL,                  -- Lượng mưa (inch)

    -- Thuộc tính phân loại (Degenerate Dimension)
    [SUNRISE_SUNSET] NVARCHAR(10) NULL,          -- Ban ngày / Ban đêm (Day / Night)

    -- Ràng buộc Khóa Ngoại
    CONSTRAINT [FK_FACT_DIM_START_DATE] FOREIGN KEY ([ID_START_DATE]) REFERENCES [dbo].[DIM_DATE]([ID_DATE]),
    CONSTRAINT [FK_FACT_DIM_START_TIME] FOREIGN KEY ([ID_START_TIME]) REFERENCES [dbo].[DIM_TIME]([ID_TIME]),
    CONSTRAINT [FK_FACT_DIM_END_DATE] FOREIGN KEY ([ID_END_DATE]) REFERENCES [dbo].[DIM_DATE]([ID_DATE]),
    CONSTRAINT [FK_FACT_DIM_END_TIME] FOREIGN KEY ([ID_END_TIME]) REFERENCES [dbo].[DIM_TIME]([ID_TIME]),
    CONSTRAINT [FK_FACT_DIM_LOCATION] FOREIGN KEY ([ID_LOCATION]) REFERENCES [dbo].[DIM_LOCATION]([ID_LOCATION]),
    CONSTRAINT [FK_FACT_DIM_ROAD_STRUCTURE] FOREIGN KEY ([ID_ROAD_STRUCTURE]) REFERENCES [dbo].[DIM_ROAD_STRUCTURE]([ID_ROAD_STRUCTURE]),
    CONSTRAINT [FK_FACT_DIM_TRAFFIC_SIGNAL] FOREIGN KEY ([ID_TRAFFIC_SIGNAL]) REFERENCES [dbo].[DIM_TRAFFIC_SIGNAL]([ID_TRAFFIC_SIGNAL]),
    CONSTRAINT [FK_FACT_DIM_SEVERITY] FOREIGN KEY ([ID_SEVERITY]) REFERENCES [dbo].[DIM_SEVERITY]([ID_SEVERITY]),
    CONSTRAINT [FK_FACT_DIM_WEATHER] FOREIGN KEY ([ID_WEATHER]) REFERENCES [dbo].[DIM_WEATHER]([ID_WEATHER])
);
GO

SELECT * FROM [dbo].[FACT_ACCIDENT];
TRUNCATE TABLE [dbo].[FACT_ACCIDENT];
GO

SELECT *
FROM dbo.DIM_TIME;