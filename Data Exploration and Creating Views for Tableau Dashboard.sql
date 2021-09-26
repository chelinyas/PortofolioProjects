
--Cleaning Data

-- Standardize Date Format

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select *
From NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress, 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2,LEN(PropertyAddress)-CHARINDEX(',', PropertyAddress)+1) City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255), PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1),
	PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2,LEN(PropertyAddress)-CHARINDEX(',', PropertyAddress)+1)


SELECT OwnerAddress
FROM NashvilleHousing

SELECT OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255), OwnerSplitCity Nvarchar(255), OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
		END

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueId
					) Row_num
FROM NashvilleHousing
)

SELECT*
FROM RownumCTE
WHERE Row_num > 1

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




















