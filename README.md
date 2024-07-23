# gridPresence

## Transform counts to presence

The gridPresence script transform data counts to presence for a vectorial layer by intersecting both layers. 

If any of the count features that intersect with the presence features are greater than zero, presence feature will change to 1, otherwise it will remain as 0. 

See in the below image and example of count transformation to a grid.

![Only presence transformation](https://github.com/robinilla/gridPresence/blob/main/TransformationToOnlyPresence.png)
