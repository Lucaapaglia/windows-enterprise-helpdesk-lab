# My Finance drive is missing

This guide is for Finance users on a Windows 11 PC in the lab. The Finance folder normally appears as **F:** under **This PC** in File Explorer.

## Try opening the folder directly

1. Press **Windows key + E** to open File Explorer.
2. Click the address bar, enter `\\LAB-DC01\Finance` and press **Enter**.
3. Use the row below that matches what you see.

| What you see | What to do |
| --- | --- |
| The Finance folder opens | You can use your files from this window. If **F:** is still missing under **This PC**, tell the service desk that the folder opens by its full path. That gives them a drive-mapping issue to investigate. |
| Windows says “Access is denied” | If the service desk just restored your access, save your work, sign out of Windows and sign back in. Try the same path again. If access is still denied or this is your first request for access, contact the service desk. |
| Windows says it cannot find or reach the path | In the same address bar, try `\\LAB-DC01\Public`. Tell the service desk whether Public opened and give the exact error you saw for Finance. |

## What to include in a ticket

Give the PC name (under **Settings → System → About**), the time of the problem, the path you tried and the exact error. Mention whether the Finance drive worked previously. A message can be as short as this example.

> I'm on LAB-PC01. My Finance drive worked yesterday. Today F: is missing. I can open the Public folder, but opening `\\LAB-DC01\Finance` gives me “Access is denied.”

For the technician's investigation and the test used to close a similar case, see [ticket 001](../tickets/001-finance-share-access.md).
