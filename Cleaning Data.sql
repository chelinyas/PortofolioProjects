

--Cleaning Data
-- Standardize Date Format


UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

-- Populate Property Address data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID
	,a.PropertyAddress
	,b.ParcelID
	,b.PropertyAddress
	,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
	,SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress) + 1) City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing ADD PropertySplitAddress NVARCHAR(255)
	,PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
	,PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress) + 1)

SELECT OwnerAddress
FROM NashvilleHousing

SELECT OwnerAddress
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing ADD OwnerSplitAddress NVARCHAR(255)
	,OwnerSplitCity NVARCHAR(255)
	,OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	,OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	,OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		ELSE SoldAsVacant
		END

SELECT DISTINCT (SoldAsVacant)
FROM NashvilleHousing

	-- Remove Duplicates

	WITH RowNumCTE AS (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ParcelID
				,PropertyAddress
				,SalePrice
				,SaleDate
				,LegalReference ORDER BY UniqueId
				) Row_num
		FROM NashvilleHousing
		)

SELECT *
FROM RownumCTE
WHERE Row_num > 1

-- Delete Unused Columns

ALTER TABLE NashvilleHousing

DROP COLUMN OwnerAddress
	,TaxDistrict
	,PropertyAddress
	,SaleDate
