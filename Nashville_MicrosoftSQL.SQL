-- Cleaning Data in SQL Queries

SELECT *
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]


-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]


UPDATE nashville_housing_data
SET SaleDate = CONVERT(Date, saledate)

ALTER TABLE Nashville_Housing_Data
Add SaleDateConverted Date;


UPDATE nashville_housing_data
SET SaleDateConverted = CONVERT(Date, saledate)




-- Populate Property Address data
SELECT propertyaddress
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]
WHERE propertyaddress is null


SELECT *
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]
WHERE propertyaddress is null


SELECT *
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]
WHERE propertyaddress is null
order by Parcelid


SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data] a
JOIN [Portfolio Projects].[dbo].[Nashville_Housing_Data] b
    on a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is null


SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data] a
JOIN [Portfolio Projects].[dbo].[Nashville_Housing_Data] b
    on a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is null


Update a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data] a
JOIN [Portfolio Projects].[dbo].[Nashville_Housing_Data] b
    on a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is null


--Breaking out Address into individual Columns (Address, City, State)

SELECT propertyaddress
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]
--WHERE propertyaddress is null
--order by Parcelid


SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Address
, SUBSTRING(propertyaddress,  CHARINDEX(',', propertyaddress) + 1, LEN(PROPERTYADDRESS)) as Address
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]

ALTER TABLE Nashville_Housing_Data
Add PropertySplitAddress Nvarchar(225);


UPDATE nashville_housing_data
SET PropertySplitAddress  = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

ALTER TABLE Nashville_Housing_Data
Add PropertySplitCity  Nvarchar(225);


UPDATE nashville_housing_data
SET PropertySplitCity  =  SUBSTRING(propertyaddress,  CHARINDEX(',', propertyaddress) + 1, LEN(PROPERTYADDRESS))


SELECT owneraddress
FROM  [Portfolio Projects].[dbo].[Nashville_Housing_Data]

SELECT
PARSENAME(REPLACE(owneraddress, ',','.') ,3)
,PARSENAME(REPLACE(owneraddress, ',','.') ,2)
,PARSENAME(REPLACE(owneraddress, ',','.') ,1)
FROM  [Portfolio Projects].[dbo].[Nashville_Housing_Data]



ALTER TABLE Nashville_Housing_Data
Add OwnerSplitAddress Nvarchar(225);


UPDATE nashville_housing_data
SET OwnerSplitAddress  = PARSENAME(REPLACE(owneraddress, ',','.') ,3)


ALTER TABLE Nashville_Housing_Data
Add OwnerSplitCity  Nvarchar(225);


UPDATE nashville_housing_data
SET OwnerSplitCity  =  PARSENAME(REPLACE(owneraddress, ',','.') ,2)


ALTER TABLE Nashville_Housing_Data
Add OwnerSplitState Nvarchar(225);


UPDATE nashville_housing_data
SET OwnerSplitState  = PARSENAME(REPLACE(owneraddress, ',','.') ,1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(Soldasvacant), Count(Soldasvacant)
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]
GROUP BY SoldAsVacant
order by 2

SELECT SoldAsVacant
,CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]


UPDATE nashville_housing_data
SET SoldAsVacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


-- Remove Duplicates

WITH RownumCTE as (
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY parcelid,
			     propertyaddress,
				 Saleprice,
				 legalreference
				 ORDER BY
				 uniqueid
				 ) row_num
FROM [Portfolio Projects].[dbo].[Nashville_Housing_Data]
--order by ParcelID
)
DELETE
FROM RownumCTE
WHERE row_num > 1
--order by PropertyAddress
