<!--
  PhotoAttribution — renders a minimal CC credit line.
  Use wherever a third-party photo appears.

  Props mirror the attribution_* columns on gallery_photos / map_regions.
  Renders nothing if both author and license are absent.

  Styling: pass class="attr--dark" or "attr--light" to the component
  for context-appropriate colours (dark bg = slideshow, light bg = overlay).
-->
<template>
  <div v-if="author || license" class="photo-attribution">
    <span class="attr-prefix">Photo: </span>
    <a
      v-if="author && sourceUrl"
      :href="sourceUrl"
      target="_blank" rel="noopener noreferrer"
      class="attr-link"
    >{{ author }}</a>
    <span v-else-if="author">{{ author }}</span>
    <template v-if="license">
      <span class="attr-sep"> · </span>
      <a
        v-if="licenseUrl"
        :href="licenseUrl"
        target="_blank" rel="noopener noreferrer"
        class="attr-link"
      >{{ license }}</a>
      <span v-else>{{ license }}</span>
    </template>
    <span v-if="changes" class="attr-changes"> ({{ changes }})</span>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  author?:      string | null
  sourceUrl?:   string | null
  license?:     string | null
  licenseUrl?:  string | null
  changes?:     string | null
}>()
</script>

<style lang="scss" scoped>
.photo-attribution {
  font-size: 10px;
  line-height: 1.4;
  color: rgba(255, 255, 255, 0.45);

  .attr-link {
    color: rgba(255, 255, 255, 0.6);
    text-decoration: underline;
    text-underline-offset: 2px;
    &:hover { color: rgba(255, 255, 255, 0.9); }
  }

  // Light-context override — pass class="attr--light" on the component
  &.attr--light {
    color: rgba(0, 0, 0, 0.45);
    .attr-link {
      color: rgba(0, 0, 0, 0.6);
      &:hover { color: #000; }
    }
  }
}
</style>
