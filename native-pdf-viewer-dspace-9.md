# Native PDF Viewer for DSpace 9

This patch implements an embedded PDF viewer directly on the DSpace 9 item page, allowing users to view documents without downloading them first. The implementation is cleanly integrated into the `custom` theme.

## 1. Applying the Patch

Download the file [scripts/pdf-viewer.patch](scripts/pdf-viewer.patch) to the root directory of your DSpace Angular installation.
Open a terminal in the project root and run the following commands:

```shell
git apply pdf-viewer.patch
```
## 3. Translations
There might be some issues in the translation files (`en`, `es`, and `pt-br`), which you may need to fix manually.  
If you can translate into other languages, run the following command:
```
npm run merge-i18n -- -s src/themes/[YOUR-THEME]/assets/i18n
```
Then, translate the PDF-related keys.

## 4. Enabling the PDF Viewer

Locate the "mediaViewer" section in the `config.yml` file and enable the PDF option by setting it to true:

```
mediaViewer:
  image: false
  video: false
  pdf: true
```

## 5. Start/Restart the Server

