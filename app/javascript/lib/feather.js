import feather from "feather-icons/dist/feather"

// Replace all <i data-feather="*"> elements with an SVG icon
export function setupFeatherIcons() {
  feather.replace({
    width: 20,
    height: 20,
    class: "feather-icon",
  });
}