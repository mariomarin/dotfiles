-- Disable latex support in render-markdown to avoid warnings
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      latex = {
        enabled = false,
      },
    },
  },
}
