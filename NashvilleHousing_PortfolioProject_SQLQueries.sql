/*
This is a data cleaning project based on the third part of the "Data Analytics Portfolio Projects" playlist on the "Alex The Analyst" Youtube channel.
*/


SELECT *
FROM NashvilleHousing


-- Simplify Date format

Select SaleDateSimple
FROM PortfolioProject..NashvilleHousing

ALTER Table NashvilleHousing
Add SaleDateSimple date;

Update NashvilleHousing
Set SaleDateSimple =  CONVERT(date, SaleDate)


-- Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


UPDATE a
Set a.PropertyAddress = b.PropertyAddress
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Splitting Address into [Address, City, State] columns

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
	   SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) Address

From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertyAddressSplit Nvarchar(255);

Alter Table NashvilleHousing
Add PropertyCitySplit Nvarchar(255);

Update NashvilleHousing
Set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update NashvilleHousing
Set PropertyCitySplit = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerAddressSplit Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerCitySplit Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerStateSplit Nvarchar(255);

UPDATE NashvilleHousing
Set OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
Set OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
Set OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
From PortfolioProject..NashvilleHousing


-- Standerdizing SoldAsVacant Column

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
END
From PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
Set SoldAsVacant = 
CASE
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
END


-- Removing Duplicates

With RowNum_CTE AS(
Select *, ROW_NUMBER() OVER
	(
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID
	) row_num
From PortfolioProject..NashvilleHousing
)
SELECT * --DELETE
From RowNum_CTE
Where row_num > 1


Select *
From PortfolioProject..NashvilleHousing


-- Remove Unused Columns

SELECT *
From PortfolioProject..NashvilleHousing

ALTER Table PortfolioProject..NashvilleHousing
DROP Column OwnerAddress, PropertyAddress, SaleDate, TaxDistrict