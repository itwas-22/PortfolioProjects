--Data Cleaning 

--Cleaning Data in SQL Queries


Select *
fROM PortfolioProject.dbo.[NashvilleHousing ]

--Note : Data View
--------------------------------------------------------------------------------------------------------------------------------

--1. Standardize date format

Select SaleDate
fROM PortfolioProject.dbo.[NashvilleHousing ]

--Note : As you can see right now it's a date time format. We will take the time off, we will convet into date take saledate and :

Select SaleDate, CONVERT(date,SaleDate) --as SaleDate1
fROM PortfolioProject.dbo.[NashvilleHousing ]

--Note : Inorder to update this date format into the entire data set : 

Select SaleDate, CONVERT(date,SaleDate) 
fROM PortfolioProject.dbo.[NashvilleHousing ]

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Note : As you can see this has not updated the table 

Select saledateconverted, CONVERT(date,SaleDate) 
fROM PortfolioProject.dbo.[NashvilleHousing ]


Alter table NashvilleHousing
Add saledateconverted date;


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Now when you view the data you see the changes

--------------------------------------------------------------------------------------------------------------------------------

--Populate property address

Select *
fROM PortfolioProject.dbo.[NashvilleHousing ]
where PropertyAddress is null 

--Where the property address is null
--Concern here is that, Property address idealy should not be NULL, Owners might chnage nut the address of the property will remain same
--We can certainly get the property address if we had a refeernce point to base that off 

Select *
fROM PortfolioProject.dbo.[NashvilleHousing ]
order by ParcelID

--Note : #015 14 0 060.00 - this is a repetitive ID and provides property address as well 

--We can use if condition, if this parcelID has an address and this parcelID does not have an address let's populate it with this address that's 
--already populated becaue we know these are going to be the same.
--Npte : this requires self join 

Select *
fROM PortfolioProject.dbo.[NashvilleHousing ] a
JOIN PortfolioProject.dbo.[NashvilleHousing ] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]

--Note : So all we have done here is we've joined these the same exact table to itself and we said where the parcel id is the same but it's not 
--the same row because this is a uniqueID/ A Uniquw will never or that means these will never repeat themself so we'll never get the same one so if 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
fROM PortfolioProject.dbo.[NashvilleHousing ] a
JOIN PortfolioProject.dbo.[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Note : This code shows that ParcelID brings the postalAddress, it's blank in all 35 of these address for all of these but we're not populaing
-- it so what we want to do is we want to use 'Isnull' - what do we want to check is null and replace it with b.propertyaddress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
fROM PortfolioProject.dbo.[NashvilleHousing ] a
JOIN PortfolioProject.dbo.[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Now we need to update the table

--Please note when we update a join we use the alias i.e a and not nashvillhousing

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
fROM PortfolioProject.dbo.[NashvilleHousing ] a
JOIN PortfolioProject.dbo.[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)

--Note : In the below datta we notice that there is comma after all of them and then the city is mentioned
--In the Excel data there are no commas, except for inbetween these things as a separator as aa delimeter

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--We will use substring and charindex


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

--Note : creaate new columns 
--We can't separate two values into from one column without creating two other columns so jus like we added this table up here - Alter table 

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Excute one by one 

Select *
From PortfolioProject.dbo.NashvilleHousing

--Note : at the end new 2 columns have been added

--OWNER ADDRESS

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--Note : for this we will not use substring. We will use PARSENAME, this is useful for limited data that's delimeted by specefic value 
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

--We are going to CTE and some windows function find where there are duplicate values 

--when you are doing removing duplicates we're going to have duplicate rows and we need to be able to have a way to identify those rows right
--and we need to be to have a way to identify those rows by rank/orderrank/row number

--W need to write out partition because we're going to partition this data so we're going to say partition, know what we're partitioning on 
--that's helpful, Partion should be done on columns that are unique 


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
