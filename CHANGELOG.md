# Changelog

## 0.6.0

- Map the `UTC` time zone identifier to `Etc/UTC`
- Include the name of the unrecognized time zone in error
  thrown when calling `Zonex.get_canonical!/3`

## 0.5.0

- Update `windowsZones.xml` file to include 2022g changes

## 0.4.0

- Fix metazone territories list to only include territories
  for the time zone's current metazone membership

## 0.3.0

- Rename `Zonex.list/2` to `Zonex.list_canonical/2`
- Rename `Zonex.get/3` to `Zonex.get_canonical/3`
- Rename `Zonex.get!/3` to `Zonex.get_canonical!/3`
- Rename Zone `standard` property to `golden`

## 0.2.0

- Add GitHub source URL in mix project config

## 0.1.0

- Initial release
