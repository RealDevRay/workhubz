const releaseMeta = document.getElementById('release-meta');
const downloadBtn = document.getElementById('download-apk');
const yearEl = document.getElementById('year');

if (yearEl) {
  yearEl.textContent = new Date().getFullYear().toString();
}

async function hydrateLatestRelease() {
  const fallbackUrl = 'https://github.com/RealDevRay/workhubz/releases/latest';

  try {
    const response = await fetch('https://api.github.com/repos/RealDevRay/workhubz/releases/latest', {
      headers: {
        Accept: 'application/vnd.github+json',
      },
    });

    if (!response.ok) {
      throw new Error(`GitHub API returned ${response.status}`);
    }

    const release = await response.json();
    const assets = Array.isArray(release.assets) ? release.assets : [];
    const apk = assets.find((asset) =>
      typeof asset?.name === 'string' && asset.name.toLowerCase().endsWith('.apk'),
    );

    if (apk?.browser_download_url) {
      downloadBtn.href = apk.browser_download_url;
      downloadBtn.textContent = `Download Android APK (${release.tag_name})`;
      releaseMeta.textContent = `Latest build: ${release.tag_name} • Updated ${new Date(release.published_at).toLocaleDateString()}`;
    } else {
      downloadBtn.href = fallbackUrl;
      releaseMeta.textContent = 'Latest release found. Open releases to download APK.';
    }
  } catch (error) {
    downloadBtn.href = fallbackUrl;
    releaseMeta.textContent = 'Could not fetch latest build automatically. Open GitHub Releases.';
    console.warn('Failed to fetch latest release', error);
  }
}

hydrateLatestRelease();
