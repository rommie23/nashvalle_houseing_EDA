/* 
cleaning data using SQL
*/

select * from ..nashville_housing_data

-- Check sale date data type--
select "saledate"
from ..nashville_housing_data

-- populate property address data--
select *
from ..nashville_housing_data
where propertyaddress is null

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from ..nashville_housing_data a
join ..nashville_housing_data b
on a.parcelid = b.parcelid 
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
SET propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
FROM ..nashville_housing_data a
join ..nashville_housing_data b
on a.parcelid = b.parcelid 
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

-- breaking out address into Individual columns (Address, City, State)

select PropertyAddress
from ..nashville_housing_data

select SUBSTRING(propertyaddress, 1 , charindex( ',' , propertyaddress)-1) as address,
SUBSTRING(propertyaddress, charindex( ',' , propertyaddress)+1, LEN(propertyaddress)) as address_2
from ..nashville_housing_data

alter table nashville_housing_data
add propery_split_address nvarchar(255);

update nashville_housing_data
set propery_split_address = SUBSTRING(propertyaddress, 1 , charindex( ',' , propertyaddress)-1)


alter table nashville_housing_data
add propery_split_city nvarchar(255);

update nashville_housing_data
set propery_split_city = SUBSTRING(propertyaddress, charindex( ',' , propertyaddress)+1, LEN(propertyaddress))

select propertyaddress, propery_split_address, propery_split_city
from nashville_housing_data



-- breaking out address into Individual columns (Address, City, State)

select owneraddress
from portfolio_project.dbo.nashville_housing_data

select 
PARSENAME(replace(owneraddress, ',', '.'),3),
PARSENAME(replace(owneraddress, ',', '.'),2),
PARSENAME(replace(owneraddress, ',', '.'),1)
from nashville_housing_data


alter table nashville_housing_data
add owner_address_1 nvarchar(255);

update nashville_housing_data
set owner_address_1 = PARSENAME(replace(owneraddress, ',', '.'),3)


alter table nashville_housing_data
add owner_address_2 nvarchar(255);

update nashville_housing_data
set owner_address_2 = PARSENAME(replace(owneraddress, ',', '.'),2)

alter table nashville_housing_data
add owner_address_3 nvarchar(255);

update nashville_housing_data
set owner_address_3 = PARSENAME(replace(owneraddress, ',', '.'),1)

select * 
from ..nashville_housing_data

-- change Y an N to yes and no in 'sold as vacant' column

select distinct(SoldAsVacant)
from ..nashville_housing_data

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from ..nashville_housing_data
group by SoldAsVacant


select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

from ..nashville_housing_data

update nashville_housing_data
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end



-- Remove duplicates--

select * 
from ..nashville_housing_data


With RowNumCTE as(
select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
				 ) row_num

from ..nashville_housing_data
--order by ParcelID
)

select *
from RowNumCTE
where row_num <> 1



-- Delete unused columns--

Alter table nashville_housing_data
drop column OwnerAddress, PropertyAddress,TaxDistrict

select * 
from portfolio_project.dbo.nashville_housing_data
order by SaleDate