# Q430 Master Image Creation



## Steps to create a new master image
- Make sure that all changes that you want to include have been merged to the main branch of all repositories.
- Create a new tag on this repository
- Trigger the pipeline from the new tag with the version update that matches the changes {major.minor.patch}
  - patch is the default version to update
  - major is for versions that have significant changes
  - minor is for when there are features added that are more significant than a patch
- From this point the pipeline will create the image and place it inside the ECS as well as update the latest changes to SKALA 2.0

## Repositories Pulled Into Master Image
- [FE](https://gitlab.com/addium/software/skala/q430/q430-frontend-flutter)
- [BE](https://gitlab.com/addium/software/skala/q430/q430-enexus)
- [FW Motherboard]()
- [FW Sensor Block]()
- [OS]()

