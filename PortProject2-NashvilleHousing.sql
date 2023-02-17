
Select * 
From PortProject1.dbo.NashvilleHousing$

Select SaleDate, CONVERT(Date, SaleDate)
From PortProject1.dbo.NashvilleHousing$

-------------------------------------------------------------------------
--Convert 'SaleDate' to standadized Date format

Update NashvilleHousing$
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing$
Add SaleDateConverted Date;

Update NashvilleHousing$
SET SaleDateConverted = CONVERT(Date, SaleDate)


Select SaleDateConverted
From PortProject1.dbo.NashvilleHousing$

----------------------------------------------------------------------
--Populate Property Address

Select PropertyAddress
From PortProject1.dbo.NashvilleHousing$
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortProject1.dbo.NashvilleHousing$ a
JOIN PortProject1.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortProject1.dbo.NashvilleHousing$ a
JOIN PortProject1.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------
-- Breaking the address to individual columns (Address, City, State)
-- 1. PropertyAddress

Select PropertyAddress
From PortProject1.dbo.NashvilleHousing$

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortProject1.dbo.NashvilleHousing$

ALTER TABLE NashvilleHousing$
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing$
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select *
From PortProject1.dbo.NashvilleHousing$

-------
-- 2. Owner Address


Select OwnerAddress
From PortProject1.dbo.NashvilleHousing$


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as State
From PortProject1.dbo.NashvilleHousing$


ALTER TABLE NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousing$
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE NashvilleHousing$
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


Select *
From PortProject1.dbo.NashvilleHousing$

------------------------------------------------------------------
-- Change Y and N to 'Yes' and 'No' in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortProject1.dbo.NashvilleHousing$
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortProject1.dbo.NashvilleHousing$


Update NashvilleHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END



--------------------------------------------------------------------
-- Remove Duplicates

Select *
From PortProject1.dbo.NashvilleHousing$

Select *, ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 ORDER BY UniqueID
						 ) row_num
From PortProject1.dbo.NashvilleHousing$
order by ParcelID


WITH RowNumCTE AS(
Select *, ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 ORDER BY UniqueID
						 ) row_num
From PortProject1.dbo.NashvilleHousing$
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



WITH RowNumCTE AS(
Select *, ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 ORDER BY UniqueID
						 ) row_num
From PortProject1.dbo.NashvilleHousing$
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-------------------------------------------------------------------------------
-- Delete Unused Columns


Select *
From PortProject1.dbo.NashvilleHousing$

ALTER TABLE PortProject1.dbo.NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
















