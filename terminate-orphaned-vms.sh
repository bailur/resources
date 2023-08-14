#!/bin/bash

# delete terminated instances
for terminated_instance_uri in $(gcloud compute instances list --uri --filter="deletionProtection:true" 2> /dev/null); do
  terminated_instance_name=${terminated_instance_uri##*/}
  terminated_instance_zone_uri=${terminated_instance_uri/\/instances\/${terminated_instance_name}/}
  terminated_instance_zone=${terminated_instance_zone_uri##*/}
  if  gcloud compute instances update ${terminated_instance_name} --no-deletion-protection --zone ${terminated_instance_zone} --quiet ; then
    echo "Removed deletion protection: ${terminated_instance_zone}/${terminated_instance_name}"
  fi
  if [ -n "${terminated_instance_name}" ] && [ -n "${terminated_instance_zone}" ] && gcloud compute instances delete ${terminated_instance_name} --zone ${terminated_instance_zone} --delete-disks all --quiet; then
    echo "deleted: ${terminated_instance_zone}/${terminated_instance_name}"
  fi
done


# delete orphaned disks (filter for disks without a user)
for orphaned_disk_uri in $(gcloud compute disks list --uri --filter="-users:*" 2> /dev/null); do
  orphaned_disk_name=${orphaned_disk_uri##*/}
  orphaned_disk_zone_uri=${orphaned_disk_uri/\/disks\/${orphaned_disk_name}/}
  orphaned_disk_zone=${orphaned_disk_zone_uri##*/}
  if [ -n "${orphaned_disk_name}" ] && [ -n "${orphaned_disk_zone}" ] && gcloud compute disks delete ${orphaned_disk_name} --zone ${orphaned_disk_zone} --quiet; then
    echo "deleted: ${orphaned_disk_zone}/${orphaned_disk_name}"
  fi
done