
-- Data cleaning with sql
--In this project use Nashvile housing data

-- I learned this project from Alextheanalyst youtube channel

select * 
	from project.dbo.nashvillehousingdata


-- making SaleDate to look like normal date.

select saledate, convert(date,saledate)
	from project..nashvillehousingdata


Alter table project..nashvillehousingdata
      add SaleDateConverted Date

update project..nashvillehousingdata
	  set SaleDateConverted = convert(date,SaleDate)


--Populate property Address data which has null value


select A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
	from project..nashvillehousingdata A
	join project..nashvillehousingdata B
	on A.ParcelID = B.ParcelID
		and A.[UniqueID ] <> B.[UniqueID ]
	where A.PropertyAddress is null

update A
	set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
			from project..nashvillehousingdata A
		join project..nashvillehousingdata B
		on A.ParcelID = B.ParcelID
			and A.[UniqueID ] <> B.[UniqueID ]
		where A.PropertyAddress is null

--Breaking out Address into Individual coloumns(Address,city,states)

--First we divide PropertyAddress

select PropertyAddress 
	from project..nashvillehousingdata
	order by PropertyAddress

select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as PropertySplitAddress ,
	   substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as PropertySplitCity
	from project..nashvillehousingdata


Alter Table project..nashvillehousingdata
	Add PropertySplitAddress nvarchar(100)

Update project..nashvillehousingdata
	SET PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table project..nashvillehousingdata
	Add PropertySplitCity nvarchar(100)

Update project..nashvillehousingdata
	SET PropertySplitCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


--second we divide OwnerAddress

select OwnerAddress
	from portfolio_project..nashvillehousingdata

Select
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
    from project..nashvillehousingdata

Alter Table project..nashvillehousingdata
	Add OwnerSplitAddress nvarchar(100)

Update project..nashvillehousingdata
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Alter Table project..nashvillehousingdata
	Add OwnerSplitCity nvarchar(100)

Update project..nashvillehousingdata
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Alter Table project..nashvillehousingdata
	Add OwnerSplitState nvarchar(100)

Update project..nashvillehousingdata
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- CHANGE 'Y' AND 'N' to Yes and No in "sold as vacant" field

Select SoldAsVacant,count(SoldAsVacant)
	from project..nashvillehousingdata
	group by SoldAsVacant
	order by 2

Select SoldAsVacant,
	Case
		when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'

		Else SoldAsVacant
	End
    from project..nashvillehousingdata

update project..nashvillehousingdata
	set SoldAsVacant =
		Case
			when SoldAsVacant = 'Y' Then 'Yes'
			when SoldAsVacant = 'N' Then 'No'

			Else SoldAsVacant
		End
		from project..nashvillehousingdata


--Removing duplicate

Select * , ROW_NUMBER () Over( Partition BY ParcelID,PropertyAddress,SalePrice,SaleDate,Legalreference Order by UniqueID) rownum
	from project..nashvillehousingdata

with Duplicatefind as
	(
	Select *,ROW_NUMBER () 
		Over( Partition BY ParcelID,
						   PropertyAddress,
						   SalePrice,
						   SaleDate,
						   Legalreference
						   Order by UniqueID) as duplicatefind
	from project..nashvillehousingdata
	)

Delete
	from Duplicatefind
	where duplicatefind > 1


--deleting unused stuffs

Select *
	from project..nashvillehousingdata

Alter Table project..nashvillehousingdata
	Drop Column 
		OwnerAddress,
		TaxDistrict,
		PropertyAddress,
		SaleDate
	
	