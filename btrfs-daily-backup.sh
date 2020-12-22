#!/usr/bin/env bash
root="/data"
backup_path=$root/"snapshots" # relative to root path
subs="nickpralle leonieroeder" # btrfs subvolumes on root level wich will backed up

for subv in $subs # backup all subvolumes
do
        btrfs subvolume snapshot -r $root/$subv $backup_path/$subv-$(date +%Y%m%d)
done

snapshots=($(ls $backup_path))

backupDay=0 # day of week of long term backups (> classB) (0=Sun, 1=Mon, ... , 6=Sat)
classAdate=$(date -d "$(date +%Y%m%d) - 7 days" +%Y%m%d) # date until which every backup is to be saved (day backups; default 7 days)
classBdate=$(date -d "$(date +%Y%m%d) - 1 month" +%Y%m%d) # date until which the backup of $backupDay is to be saved (week backups; default 1 month)
classCdate=$(date -d "$(date +%Y%m%d) - 1 year" +%Y%m%d) # date until which the backup of first $backupDay (default Sunday) in month is to be saved (month backups; default 1 year)

for snapshot in ${snapshots[*]} # check if all backups are okay otherwise delete snapshot
do
        snapshot_name_split=($(echo $snapshot | tr "-" "\n"))
        datestamp=${snapshot_name_split[1]}
        printf $backup_path/$snapshot
        if [ $datestamp -gt $classAdate ];
        then # day backups
                echo " - day backup"
                continue
        elif [ $datestamp -gt $classBdate ] && [ $(date -d "$datestamp" +%w) -eq $backupDay ];
        then # week backups
                echo " - week backup"
                continue
        elif [ $datestamp -gt $classCdate ] && [ $(date -d "$datestamp" +%w) -eq $backupDay ] && [ $(date -d "$datestamp" +%d) -le 7 ];
        then # month backups
                echo " - month backup"
                continue
        elif [ $datestamp -le $classCdate ] && [ $(date -d "$datestamp" +%d) -le 7 ] && [ $(date -d "$datestamp" +%w) -eq $backupDay ];
        then # year backups
                echo " - year backup"
                continue
        else
                echo " - remove"
                btrfs sub del $backup_path/$snapshot
        fi
done
exit 0
