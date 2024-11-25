import{_ as i,c as s,a5 as e,o as a}from"./chunks/framework.DR5FrFLs.js";const k=JSON.parse('{"title":"File formats","description":"","frontmatter":{},"headers":[],"relativePath":"background/formats.md","filePath":"background/formats.md","lastUpdated":null}'),l={name:"background/formats.md"};function r(n,t,h,d,p,g){return a(),s("div",null,t[0]||(t[0]=[e(`<h1 id="File-formats" tabindex="-1">File formats <a class="header-anchor" href="#File-formats" aria-label="Permalink to &quot;File formats {#File-formats}&quot;">​</a></h1><p>We currently support the following file formats directly based on the file extension:</p><table tabindex="0"><thead><tr><th style="text-align:right;">Extension</th><th style="text-align:right;">Driver</th></tr></thead><tbody><tr><td style="text-align:right;">.shp</td><td style="text-align:right;">ESRI Shapefile</td></tr><tr><td style="text-align:right;">.gpkg</td><td style="text-align:right;">GPKG</td></tr><tr><td style="text-align:right;">.geojson</td><td style="text-align:right;">GeoJSON</td></tr><tr><td style="text-align:right;">.vrt</td><td style="text-align:right;">VRT</td></tr><tr><td style="text-align:right;">.sqlite</td><td style="text-align:right;">SQLite</td></tr><tr><td style="text-align:right;">.csv</td><td style="text-align:right;">CSV</td></tr><tr><td style="text-align:right;">.fgb</td><td style="text-align:right;">FlatGeobuf</td></tr><tr><td style="text-align:right;">.pq</td><td style="text-align:right;">Parquet</td></tr><tr><td style="text-align:right;">.arrow</td><td style="text-align:right;">Arrow</td></tr><tr><td style="text-align:right;">.gml</td><td style="text-align:right;">GML</td></tr><tr><td style="text-align:right;">.nc</td><td style="text-align:right;">netCDF</td></tr></tbody></table><p>If you get an error like so:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">GeoDataFrames</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">write</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;test.foo&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, df)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">ERROR</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> ArgumentError</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> There are no GDAL drivers </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">for</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> the </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">foo extension</span></span></code></pre></div><p>You can specifiy the driver using a keyword as follows:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">GeoDataFrames</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">write</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;test.foo&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, df; driver</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;GeoJSON&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>The complete list of driver codes are listed in the <a href="https://gdal.org/drivers/vector/index.html" target="_blank" rel="noreferrer">GDAL documentation</a>.</p>`,8)]))}const y=i(l,[["render",r]]);export{k as __pageData,y as default};