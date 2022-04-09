# snapping_horizontal_listview

An horizontal listview which has snapping scrollphysic supported

# how to use:

```dart
CustomHorizontalList<Category>(
    categories,
    itemWidth: 100,
    itemHeight: 100,
    contentPadding: 8,
    paddingBetweenItem: 8,
    listType: CustomHorizontalListType.snapping,
    itemBuilder: (category, index) => CategoryItem(category: category),
)
```