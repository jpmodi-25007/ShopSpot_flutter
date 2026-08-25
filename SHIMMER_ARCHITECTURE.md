# Shimmer Architecture

The shimmer system has been completely redesigned to replace generic loading states (like `CircularProgressIndicator` or `GenericListShimmer`) with a high-fidelity "skeleton" shimmer system that mimics the structural layout of the actual widgets.

## Core Primitives

All shimmers are built using a set of core primitives located in `lib/core/widgets/shimmer/primitives/`. These primitives automatically handle the animation and styling based on the application's theme.

- **`AppShimmer`**: The base wrapper that provides the animated gradient effect. It should wrap the entire skeleton widget or a group of shimmer primitives.
- **`ShimmerBox`**: A generic rectangular block. Ideal for images, containers, and general content areas.
- **`ShimmerText`**: A primitive specifically styled for text placeholders.
- **`ShimmerCircle`**: A circular block. Ideal for avatars, profile pictures, and circular icons.
- **`ShimmerImage`**: An alternative to `ShimmerBox` specifically optimized for representing images.
- **`ShimmerButton`**: A placeholder for buttons.

## Implementing Skeletons

To create a loading skeleton for a specific widget or screen, follow these guidelines:

1. **Analyze the Target Widget**: Look at the structure of the widget when it's fully loaded. The skeleton should match this structure as closely as possible (padding, margins, alignment, proportions).
2. **Use Primitives**: Build the skeleton using `ShimmerBox`, `ShimmerText`, and `ShimmerCircle`. Do not use hardcoded colors for the shimmer blocks; the primitives handle the theme colors.
3. **Wrap with `AppShimmer`**: Wrap the outermost container of your skeleton with `AppShimmer` to apply the animation. Avoid wrapping individual primitives if they are part of a larger structure.

### Example: Product Card Skeleton

```dart
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 16),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerText(width: double.infinity, height: 14),
                  const SizedBox(height: 4),
                  const ShimmerText(width: 60, height: 10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerText(width: 40, height: 16),
                      ShimmerBox(width: 24, height: 24, borderRadius: 8),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
```

## Usage in Screens

When a screen is in a loading state, replace the loaded content with the appropriate skeleton widget. If dealing with a list, use a `ListView.builder` or `ListView.separated` to generate multiple skeleton items.

```dart
if (state is ProductLoading) {
  return ListView.separated(
    itemCount: 4,
    separatorBuilder: (context, index) => const SizedBox(height: 16),
    itemBuilder: (context, index) => const ProductListItemSkeleton(),
  );
}
```

## File Structure

All shimmer-related files are located in `lib/core/widgets/shimmer/`.

- `shimmer.dart`: The barrel file exporting all primitives and skeletons.
- `primitives/`: Contains the core building blocks (`app_shimmer.dart`, `shimmer_box.dart`, etc.).
- `skeletons/`: Contains all specific implementations of skeletons for different parts of the app (`product_card_skeleton.dart`, `order_card_skeleton.dart`, etc.).
