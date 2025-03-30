import{_ as l,c as n,j as s,a as i,G as t,a5 as r,B as p,o}from"./chunks/framework.BXvaAh_l.js";const L=JSON.parse('{"title":"API","description":"","frontmatter":{},"headers":[],"relativePath":"reference/api.md","filePath":"reference/api.md","lastUpdated":null}'),h={name:"reference/api.md"},d={class:"jldocstring custom-block",open:""},k={class:"jldocstring custom-block",open:""},g={class:"jldocstring custom-block",open:""},c={class:"jldocstring custom-block",open:""},y={class:"jldocstring custom-block",open:""},u={class:"jldocstring custom-block",open:""},f={class:"jldocstring custom-block",open:""},b={class:"jldocstring custom-block",open:""},F={class:"jldocstring custom-block",open:""},m={class:"jldocstring custom-block",open:""};function E(D,e,v,j,C,G){const a=p("Badge");return o(),n("div",null,[e[36]||(e[36]=s("h1",{id:"api",tabindex:"-1"},[i("API "),s("a",{class:"header-anchor",href:"#api","aria-label":'Permalink to "API"'},"​")],-1)),s("details",d,[s("summary",null,[e[0]||(e[0]=s("a",{id:"GeoDataFrames.read",href:"#GeoDataFrames.read"},[s("span",{class:"jlbinding"},"GeoDataFrames.read")],-1)),e[1]||(e[1]=i()),t(a,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),e[2]||(e[2]=r('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">read</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(fn</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">AbstractString</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">; layer</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Union{Integer,AbstractString}</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, kwargs</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Read a file into a DataFrame. Any kwargs are passed to the driver, by default set to <a href="/GeoDataFrames.jl/previews/PR106/reference/api#GeoDataFrames.ArchGDALDriver"><code>ArchGDALDriver</code></a>.</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/io.jl#LL45-L49" target="_blank" rel="noreferrer">source</a></p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">read</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(driver</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">AbstractDriver</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, fn</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">AbstractString</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">; kwargs</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Read a file into a DataFrame using the specified driver. Any kwargs are passed to the driver, by default set to <a href="/GeoDataFrames.jl/previews/PR106/reference/api#GeoDataFrames.ArchGDALDriver"><code>ArchGDALDriver</code></a>.</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/io.jl#LL66-L70" target="_blank" rel="noreferrer">source</a></p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">read</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(driver</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ArchGDALDriver</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, fn</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">AbstractString</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">; layer</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Union{Integer,AbstractString}</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, kwargs</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Read a file into a DataFrame using the ArchGDAL driver. By default you only get the first layer, unless you specify either the index (0 based) or name (string) of the layer. Other supported kwargs are passed to the <a href="https://yeesian.com/ArchGDAL.jl/stable/reference/#ArchGDAL.read-Tuple%7BAbstractString%7D" target="_blank" rel="noreferrer">ArchGDAL read</a> method.</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/io.jl#LL76-L82" target="_blank" rel="noreferrer">source</a></p>',9))]),s("details",k,[s("summary",null,[e[3]||(e[3]=s("a",{id:"GeoDataFrames.write",href:"#GeoDataFrames.write"},[s("span",{class:"jlbinding"},"GeoDataFrames.write")],-1)),e[4]||(e[4]=i()),t(a,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),e[5]||(e[5]=r('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">write</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(fn</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">AbstractString</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, table; kwargs</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Write the provided <code>table</code> to <code>fn</code>. A driver is selected based on the extension of <code>fn</code>.</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/io.jl#LL126-L130" target="_blank" rel="noreferrer">source</a></p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">write</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(driver</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">AbstractDriver</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, fn</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">AbstractString</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, table; kwargs</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Write the provided <code>table</code> to <code>fn</code> using the specified driver. Any kwargs are passed to the driver, by default set to <a href="/GeoDataFrames.jl/previews/PR106/reference/api#GeoDataFrames.ArchGDALDriver"><code>ArchGDALDriver</code></a>.</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/io.jl#LL136-L140" target="_blank" rel="noreferrer">source</a></p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">write</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(driver</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ArchGDALDriver</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, fn</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">AbstractString</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, table; layer_name</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;data&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, crs</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Union{GFT.GeoFormat,Nothing}</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">getcrs</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(table), driver</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Union{Nothing,AbstractString}</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">nothing</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, options</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Dict{String,String}</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Dict</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(), geom_columns</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Tuple{Symbol}</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">getgeometrycolumns</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(table), kwargs</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Write the provided <code>table</code> to <code>fn</code> using the ArchGDAL driver.</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/io.jl#LL146-L150" target="_blank" rel="noreferrer">source</a></p>',9))]),s("details",g,[s("summary",null,[e[6]||(e[6]=s("a",{id:"GeoDataFrames.reproject",href:"#GeoDataFrames.reproject"},[s("span",{class:"jlbinding"},"GeoDataFrames.reproject")],-1)),e[7]||(e[7]=i()),t(a,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),e[8]||(e[8]=r('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">reproject</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(df</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">DataFrame</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, to_crs; [always_xy</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">])</span></span></code></pre></div><p>Reproject the geometries in a DataFrame <code>df</code> to a new Coordinate Reference System <code>to_crs</code>, from the current CRS. See also <a href="/GeoDataFrames.jl/previews/PR106/reference/api#GeoDataFrames.reproject"><code>reproject(df, from_crs, to_crs)</code></a> and the in place version <a href="/GeoDataFrames.jl/previews/PR106/reference/api#GeoDataFrames.reproject!"><code>reproject!(df, to_crs)</code></a>. <code>always_xy</code> (<code>false</code> by default) can override the default axis mapping strategy of the CRS. If true, input is assumed to be in the traditional GIS order (longitude, latitude).</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/utils.jl#LL104-L111" target="_blank" rel="noreferrer">source</a></p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">reproject</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(df</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">DataFrame</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, from_crs, to_crs; [always_xy</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">])</span></span></code></pre></div><p>Reproject the geometries in a DataFrame <code>df</code> from the crs <code>from_crs</code> to a new crs <code>to_crs</code>. This overrides any current CRS of the Dataframe.</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/utils.jl#LL116-L121" target="_blank" rel="noreferrer">source</a></p>',6))]),s("details",c,[s("summary",null,[e[9]||(e[9]=s("a",{id:"GeoDataFrames.reproject!",href:"#GeoDataFrames.reproject!"},[s("span",{class:"jlbinding"},"GeoDataFrames.reproject!")],-1)),e[10]||(e[10]=i()),t(a,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),e[11]||(e[11]=r('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">reproject!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(df</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">DataFrame</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, to_crs; [always_xy</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">])</span></span></code></pre></div><p>Reproject the geometries in a DataFrame <code>df</code> to a new Coordinate Reference System <code>to_crs</code>, from the current CRS, in place.</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/utils.jl#LL126-L130" target="_blank" rel="noreferrer">source</a></p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">reproject!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(df</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">DataFrame</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, from_crs, to_crs; [always_xy</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">])</span></span></code></pre></div><p>Reproject the geometries in a DataFrame <code>df</code> from the crs <code>from_crs</code> to a new crs <code>to_crs</code> in place. This overrides any current CRS of the Dataframe.</p><p><a href="https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/utils.jl#LL135-L140" target="_blank" rel="noreferrer">source</a></p>',6))]),e[37]||(e[37]=s("h2",{id:"drivers",tabindex:"-1"},[i("Drivers "),s("a",{class:"header-anchor",href:"#drivers","aria-label":'Permalink to "Drivers"'},"​")],-1)),e[38]||(e[38]=s("p",null,"The following drivers are provided:",-1)),s("details",y,[s("summary",null,[e[12]||(e[12]=s("a",{id:"GeoDataFrames.GeoJSONDriver",href:"#GeoDataFrames.GeoJSONDriver"},[s("span",{class:"jlbinding"},"GeoDataFrames.GeoJSONDriver")],-1)),e[13]||(e[13]=i()),t(a,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[14]||(e[14]=s("p",null,"GeoJSON driver",-1)),e[15]||(e[15]=s("p",null,[s("a",{href:"https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/drivers.jl#LL3-L5",target:"_blank",rel:"noreferrer"},"source")],-1))]),s("details",u,[s("summary",null,[e[16]||(e[16]=s("a",{id:"GeoDataFrames.ShapefileDriver",href:"#GeoDataFrames.ShapefileDriver"},[s("span",{class:"jlbinding"},"GeoDataFrames.ShapefileDriver")],-1)),e[17]||(e[17]=i()),t(a,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[18]||(e[18]=s("p",null,"Shapefile driver",-1)),e[19]||(e[19]=s("p",null,[s("a",{href:"https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/drivers.jl#LL7-L9",target:"_blank",rel:"noreferrer"},"source")],-1))]),s("details",f,[s("summary",null,[e[20]||(e[20]=s("a",{id:"GeoDataFrames.GeoParquetDriver",href:"#GeoDataFrames.GeoParquetDriver"},[s("span",{class:"jlbinding"},"GeoDataFrames.GeoParquetDriver")],-1)),e[21]||(e[21]=i()),t(a,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[22]||(e[22]=s("p",null,"GeoParquet driver",-1)),e[23]||(e[23]=s("p",null,[s("a",{href:"https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/drivers.jl#LL11-L13",target:"_blank",rel:"noreferrer"},"source")],-1))]),s("details",b,[s("summary",null,[e[24]||(e[24]=s("a",{id:"GeoDataFrames.FlatGeobufDriver",href:"#GeoDataFrames.FlatGeobufDriver"},[s("span",{class:"jlbinding"},"GeoDataFrames.FlatGeobufDriver")],-1)),e[25]||(e[25]=i()),t(a,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[26]||(e[26]=s("p",null,"FlatGeobuf driver",-1)),e[27]||(e[27]=s("p",null,[s("a",{href:"https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/drivers.jl#LL15-L17",target:"_blank",rel:"noreferrer"},"source")],-1))]),s("details",F,[s("summary",null,[e[28]||(e[28]=s("a",{id:"GeoDataFrames.ArchGDALDriver",href:"#GeoDataFrames.ArchGDALDriver"},[s("span",{class:"jlbinding"},"GeoDataFrames.ArchGDALDriver")],-1)),e[29]||(e[29]=i()),t(a,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[30]||(e[30]=s("p",null,"ArchGDAL driver (default)",-1)),e[31]||(e[31]=s("p",null,[s("a",{href:"https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/drivers.jl#LL19-L21",target:"_blank",rel:"noreferrer"},"source")],-1))]),s("details",m,[s("summary",null,[e[32]||(e[32]=s("a",{id:"GeoDataFrames.GeoArrowDriver",href:"#GeoDataFrames.GeoArrowDriver"},[s("span",{class:"jlbinding"},"GeoDataFrames.GeoArrowDriver")],-1)),e[33]||(e[33]=i()),t(a,{type:"info",class:"jlObjectType jlType",text:"Type"})]),e[34]||(e[34]=s("p",null,"GeoArrow driver",-1)),e[35]||(e[35]=s("p",null,[s("a",{href:"https://github.com/evetion/GeoDataFrames.jl/blob/fe8476e99788dd5b86a6007086f5ef63c14e3de1/src/drivers.jl#LL23-L25",target:"_blank",rel:"noreferrer"},"source")],-1))]),e[39]||(e[39]=s("p",null,[i("These can be passed to the "),s("a",{href:"/GeoDataFrames.jl/previews/PR106/reference/api#GeoDataFrames.read"},[s("code",null,"read")]),i(" and "),s("a",{href:"/GeoDataFrames.jl/previews/PR106/reference/api#GeoDataFrames.write"},[s("code",null,"write")]),i(" functions as the first argument, but require the corresponding package to be loaded. You can find the corresponding package to load in the "),s("a",{href:"/GeoDataFrames.jl/previews/PR106/reference/api#package-extensions"},"package extensions"),i(" section.")],-1))])}const B=l(h,[["render",E]]);export{L as __pageData,B as default};
