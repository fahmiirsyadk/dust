module Html = {
  module Elements = {
    open Internal__Dust_Syntax_Compiler

    let text = (node: string) => list{node}
    let a = (attrs, children) => Paired->render("a", attrs, children)
    let abbr = (attrs, children) => Paired->render("abbr", attrs, children)
    let address = (attrs, children) => Paired->render("address", attrs, children)
    let area = (attrs, children) => Paired->render("area", attrs, children)
    let article = (attrs, children) => Paired->render("article", attrs, children)
    let aside = (attrs, children) => Paired->render("aside", attrs, children)
    let audio = (attrs, children) => Paired->render("audio", attrs, children)
    let b = (attrs, children) => Paired->render("b", attrs, children)
    let base = (attrs, children) => Paired->render("base", attrs, children)
    let bdi = (attrs, children) => Paired->render("bdi", attrs, children)
    let bdo = (attrs, children) => Paired->render("bdo", attrs, children)
    let blockquotes = (attrs, children) => Paired->render("blockquotes", attrs, children)
    let body = (attrs, children) => Paired->render("body", attrs, children)
    let br = (attrs, children) => Paired->render("br", attrs, children)
    let button = (attrs, children) => Paired->render("button", attrs, children)
    let canvas = (attrs, children) => Paired->render("canvas", attrs, children)
    let caption = (attrs, children) => Paired->render("caption", attrs, children)
    let cite = (attrs, children) => Paired->render("cite", attrs, children)
    let code = (attrs, children) => Paired->render("code", attrs, children)
    let col = (attrs, children) => Paired->render("col", attrs, children)
    let colgroup = (attrs, children) => Paired->render("colgroup", attrs, children)
    let command = (attrs, children) => Paired->render("command", attrs, children)
    let datalist = (attrs, children) => Paired->render("datalist", attrs, children)
    let dd = (attrs, children) => Paired->render("dd", attrs, children)
    let del = (attrs, children) => Paired->render("del", attrs, children)
    let details = (attrs, children) => Paired->render("details", attrs, children)
    let dfn = (attrs, children) => Paired->render("dfn", attrs, children)
    let dialog = (attrs, children) => Paired->render("dialog", attrs, children)
    let div = (attrs, children) => Paired->render("div", attrs, children)
    let dl = (attrs, children) => Paired->render("dl", attrs, children)
    let dt = (attrs, children) => Paired->render("dt", attrs, children)
    let em = (attrs, children) => Paired->render("em", attrs, children)
    let embed = (attrs, children) => Paired->render("embed", attrs, children)
    let figcation = (attrs, children) => Paired->render("figcation", attrs, children)
    let figure = (attrs, children) => Paired->render("figure", attrs, children)
    let footer = (attrs, children) => Paired->render("footer", attrs, children)
    let form = (attrs, children) => Paired->render("form", attrs, children)
    let h1 = (attrs, children) => Paired->render("h1", attrs, children)
    let h2 = (attrs, children) => Paired->render("h2", attrs, children)
    let h3 = (attrs, children) => Paired->render("h3", attrs, children)
    let h4 = (attrs, children) => Paired->render("h4", attrs, children)
    let h5 = (attrs, children) => Paired->render("h5", attrs, children)
    let h6 = (attrs, children) => Paired->render("h6", attrs, children)
    let head = (attrs, children) => Paired->render("head", attrs, children)
    let header = (attrs, children) => Paired->render("header", attrs, children)
    let hr = (attrs, children) => Paired->render("hr", attrs, children)
    let html = (attrs, children) => Paired->render("html", attrs, children)
    let i = (attrs, children) => Paired->render("i", attrs, children)
    let iframe = (attrs, children) => Paired->render("iframe", attrs, children)
    let img = (attrs, children) => Single->render("img", attrs, children)
    let input = (attrs, children) => Single->render("input", attrs, children)
    let ins = (attrs, children) => Paired->render("ins", attrs, children)
    let kbd = (attrs, children) => Paired->render("kbd", attrs, children)
    let label = (attrs, children) => Paired->render("label", attrs, children)
    let legend = (attrs, children) => Paired->render("legend", attrs, children)
    let li = (attrs, children) => Paired->render("li", attrs, children)
    let link = (attrs, children) => Single->render("link", attrs, children)
    let main = (attrs, children) => Paired->render("main", attrs, children)
    let map = (attrs, children) => Paired->render("map", attrs, children)
    let mark = (attrs, children) => Paired->render("mark", attrs, children)
    let menu = (attrs, children) => Paired->render("menu", attrs, children)
    let menuItem = (attrs, children) => Paired->render("menuItem", attrs, children)
    let meta = (attrs, children) => Single->render("meta", attrs, children)
    let meter = (attrs, children) => Paired->render("meter", attrs, children)
    let nav = (attrs, children) => Paired->render("nav", attrs, children)
    let noscript = (attrs, children) => Paired->render("noscript", attrs, children)
    // object is a reserved keyword
    let object_ = (attrs, children) => Paired->render("object", attrs, children)
    let ul = (attrs, children) => Paired->render("ul", attrs, children)
    let ol = (attrs, children) => Paired->render("ol", attrs, children)
    let optgroup = (attrs, children) => Paired->render("optgroup", attrs, children)
    let p = (attrs, children) => Paired->render("p", attrs, children)
    let param = (attrs, children) => Paired->render("param", attrs, children)
    let pre = (attrs, children) => Paired->render("pre", attrs, children)
    let q = (attrs, children) => Paired->render("q", attrs, children)
    let rp = (attrs, children) => Paired->render("rp", attrs, children)
    let rt = (attrs, children) => Paired->render("rt", attrs, children)
    let ruby = (attrs, children) => Paired->render("ruby", attrs, children)
    let samp = (attrs, children) => Paired->render("samp", attrs, children)
    let script = (attrs, children) => Paired->render("script", attrs, children)
    let section = (attrs, children) => Paired->render("section", attrs, children)
    let select = (attrs, children) => Paired->render("select", attrs, children)
    let small = (attrs, children) => Paired->render("small", attrs, children)
    let source = (attrs, children) => Paired->render("source", attrs, children)
    let span = (attrs, children) => Paired->render("span", attrs, children)
    let strong = (attrs, children) => Paired->render("strong", attrs, children)
    let style = (attrs, children) => Paired->render("style", attrs, children)
    let sub = (attrs, children) => Paired->render("sub", attrs, children)
    let summary = (attrs, children) => Paired->render("summary", attrs, children)
    let sup = (attrs, children) => Paired->render("sup", attrs, children)
    let table = (attrs, children) => Paired->render("table", attrs, children)
    let tbody = (attrs, children) => Paired->render("tbody", attrs, children)
    let td = (attrs, children) => Paired->render("td", attrs, children)
    let textarea = (attrs, children) => Paired->render("textarea", attrs, children)
    let tfoot = (attrs, children) => Paired->render("tfoot", attrs, children)
    let th = (attrs, children) => Paired->render("th", attrs, children)
    let thead = (attrs, children) => Paired->render("thead", attrs, children)
    let time = (attrs, children) => Paired->render("time", attrs, children)
    let title = (attrs, children) => Paired->render("title", attrs, children)
    let tr = (attrs, children) => Paired->render("tr", attrs, children)
    let track = (attrs, children) => Paired->render("track", attrs, children)
    let u = (attrs, children) => Paired->render("u", attrs, children)
    let var = (attrs, children) => Paired->render("var", attrs, children)
    let video = (attrs, children) => Paired->render("video", attrs, children)
    let wbr = (attrs, children) => Paired->render("wbr", attrs, children)
  }

  module Attributes = {
    open Internal__Dust_Syntax_Compiler
    type t = typeAttr

    let accept = p => AttrString("accept", p)->attrFormat
    let acceptCharset = p => AttrString("accept-charset", p)->attrFormat
    let accesskey = p => AttrString("accesskey", p)->attrFormat
    let alt = p => AttrString("alt", p)->attrFormat
    let autofocus = p => AttrBool("autofocus", p)->attrFormat
    let action = p => AttrString("action", p)->attrFormat
    let autocomplete = p => AttrString("autocomplete", p)->attrFormat
    let autosave = p => AttrString("autosave", p)->attrFormat
    let async = p => AttrBool("async", p)->attrFormat
    let cols = p => AttrInt("cols", p)->attrFormat
    let controls = p => AttrBool("controls", p)->attrFormat
    let colspan = p => AttrInt("colspan", p)->attrFormat
    let charset = p => AttrString("charset", p)->attrFormat
    let charset2 = p => {
      let toString = switch p {
      | #UTF8 => "utf-8"
      }
      AttrString("charset", toString)->attrFormat
    }
    let content = p => AttrString("content", p)->attrFormat
    let checked = p => AttrBool("checked", p)->attrFormat
    let coords = p => AttrString("coord", p)->attrFormat
    let contenteditable = p => AttrBool("contenteditable", p)->attrFormat
    let class_ = p => AttrString("class", p)->attrFormat
    // TODO: check below this
    let cite = p => AttrString("cite", p)->attrFormat
    let data = p => AttrString("data", p)->attrFormat
    let disabled = p => AttrBool("disabled", p)->attrFormat
    let datetime = (p: Js.Date.t) => AttrString("datetime", p->Js.Date.toString)->attrFormat
    let default = p => AttrBool("default", p)->attrFormat
    let defer = p => AttrBool("defer", p)->attrFormat
    let dir = p => {
      let toString = switch p {
      | #Ltr => "ltr"
      | #Rtl => "rtl"
      | #Auto => "auto"
      }
      AttrString("dir", toString)->attrFormat
    }
    let dirname = p => AttrString("dirname", p)->attrFormat
    let download = p => AttrString("download", p)->attrFormat
    let draggable = p => {
      let toString = switch p {
      | #True => "true"
      | #False => "false"
      | #Auto => "auto"
      }
      AttrString("draggable", toString)->attrFormat
    }
    let enctype = p => {
      let toString = switch p {
      | #ApplicationXWwwFormUrlEncoded => "application/x-www-form-urlencoded"
      | #MultipartFormData => "MultipartFormData"
      | #TextPlain => "TextPlain"
      }
      AttrString("enctype", toString)->attrFormat
    }
    let for_ = p => AttrString("for", p)->attrFormat
    let form = p => AttrString("form", p)->attrFormat
    let formaction = p => AttrString("formaction", p)->attrFormat
    let header = p => AttrString("header", p)->attrFormat
    let height = p => AttrString("height", p->Js.Float.toString)->attrFormat
    let hidden = p => AttrBool("hidden", p)->attrFormat
    let high = p => AttrString("high", p->Js.Float.toString)->attrFormat
    let href = p => AttrString("href", p)->attrFormat
    let hreflang = p => AttrString("hreflang", p)->attrFormat
    let httpEquiv = p => {
      let toString = switch p {
      | #ContentSecurityPolicy => "content-security-policy"
      | #ContentType => "content-type"
      | #DefaultStyle => "default-style"
      | #Refresh => "refresh"
      }
      AttrString("httpEquiv", toString)->attrFormat
    }
    let id = p => AttrString("id", p)->attrFormat
    let ismap = p => AttrBool("ismap", p)->attrFormat
    let kind = p => {
      let toString = switch p {
      | #Caption => "captions"
      | #Chapters => "chapters"
      | #Descriptions => "descriptions"
      | #Metadata => "metadata"
      | #Subtitles => "subtitles"
      }
      AttrString("kind", toString)->attrFormat
    }
    let label = p => AttrString("label", p)->attrFormat
    let lang = p => AttrString("lang", p)->attrFormat
    let list = p => AttrString("list", p)->attrFormat
    let loop = p => AttrBool("loop", p)->attrFormat
    let low = p => AttrString("low", p->Js.Float.toString)->attrFormat
    let max = p => {
      let toString = switch p {
      | #Date(x) => x->Js.Date.toString
      | #Number(x) => x->Js.Float.toString
      }
      AttrString("max", toString)->attrFormat
    }
    let maxlength = p => AttrInt("maxlength", p)->attrFormat
    let media = p => AttrString("media", p)->attrFormat
    let method = p => {
      let toString = switch p {
      | #GET => "get"
      | #POST => "post"
      }
      AttrString("method", toString)->attrFormat
    }
    let min = p => {
      let toString = switch p {
      | #Date(x) => x->Js.Date.toString
      | #Number(x) => x->Js.Float.toString
      }
      AttrString("max", toString)->attrFormat
    }
    let meta_name = p => {
      let toString = switch p {
      | #Keyword => "keyword"
      | #Description => "description"
      | #Author => "author"
      | #Title => "title"
      | #Viewport => "viewport"
      | #Generator => "generator"
      | #ApplicationName => "application-name"
      | #ThemeColor => "theme-color"
      }
      AttrString("name", toString)->attrFormat
    }
    let multiple = p => AttrBool("multiple", p)->attrFormat
    let muted = p => AttrBool("muted", p)->attrFormat
    let name = p => AttrString("name", p)->attrFormat
    let novalidate = p => AttrBool("novalidate", p)->attrFormat
    let onabort = p => AttrString("onabort", p)->attrFormat
    let onafterprint = p => AttrString("onafterprint", p)->attrFormat
    let onbeforeprint = p => AttrString("onbeforeprint", p)->attrFormat
    let onbeforeunload = p => AttrString("onbeforeunload", p)->attrFormat
    let onblur = p => AttrString("onblur", p)->attrFormat
    let oncanplay = p => AttrString("oncanplay", p)->attrFormat
    let oncanplaythrough = p => AttrString("oncanplaythrough", p)->attrFormat
    let onclick = p => AttrString("onclick", p)->attrFormat
    let onchange = p => AttrString("onchange", p)->attrFormat
    let oncontextmenu = p => AttrString("oncontextmenu", p)->attrFormat
    let oncopy = p => AttrString("oncopy", p)->attrFormat
    let oncut = p => AttrString("oncut", p)->attrFormat
    let ondblclick = p => AttrString("ondblclick", p)->attrFormat
    let ondrag = p => AttrString("ondrag", p)->attrFormat
    let ondragend = p => AttrString("ondragend", p)->attrFormat
    let ondragenter = p => AttrString("ondragenter", p)->attrFormat
    let ondragleave = p => AttrString("ondragleave", p)->attrFormat
    let ondragstart = p => AttrString("ondragstart", p)->attrFormat
    let ondrop = p => AttrString("ondrop", p)->attrFormat
    let ondurationchange = p => AttrString("ondurationchange", p)->attrFormat
    let onemptied = p => AttrString("onemptied", p)->attrFormat
    let onended = p => AttrString("onended", p)->attrFormat
    let onerror = p => AttrString("onerror", p)->attrFormat
    let onfocus = p => AttrString("onfocus", p)->attrFormat
    let onhaschange = p => AttrString("onhaschange", p)->attrFormat
    let oninput = p => AttrString("oninput", p)->attrFormat
    let oninvalid = p => AttrString("oninvalid", p)->attrFormat
    let onkeydown = p => AttrString("onkeydown", p)->attrFormat
    let onkeypress = p => AttrString("onkeypress", p)->attrFormat
    let onkeyup = p => AttrString("onkeyup", p)->attrFormat
    let onload = p => AttrString("onload", p)->attrFormat
    let onloadeddata = p => AttrString("onloadeddata", p)->attrFormat
    let onloadedmetada = p => AttrString("onloadedmetada", p)->attrFormat
    let onloadstart = p => AttrString("onloadstart", p)->attrFormat
    let onmousedown = p => AttrString("onmousedown", p)->attrFormat
    let onmouseout = p => AttrString("onmouseout", p)->attrFormat
    let onmouseover = p => AttrString("onmouseover", p)->attrFormat
    let onmouseup = p => AttrString("onmouseup", p)->attrFormat
    let onmousewheel = p => AttrString("onmousewheel", p)->attrFormat
    let onoffline = p => AttrString("onoffline", p)->attrFormat
    let ononline = p => AttrString("ononline", p)->attrFormat
    let onpagehide = p => AttrString("onpagehide", p)->attrFormat
    let onpageshow = p => AttrString("onpageshow", p)->attrFormat
    let onpaste = p => AttrString("onpaste", p)->attrFormat
    let onpause = p => AttrString("onpause", p)->attrFormat
    let onplaying = p => AttrString("onplaying", p)->attrFormat
    let onpopstate = p => AttrString("onpopstate", p)->attrFormat
    let onprogress = p => AttrString("onprogress", p)->attrFormat
    let onratechange = p => AttrString("onratechange", p)->attrFormat
    let onreset = p => AttrString("onreset", p)->attrFormat
    let onresize = p => AttrString("onresize", p)->attrFormat
    let onscroll = p => AttrString("onscroll", p)->attrFormat
    let onsearch = p => AttrString("onsearch", p)->attrFormat
    let onseeked = p => AttrString("onseeked", p)->attrFormat
    let onselect = p => AttrString("onselect", p)->attrFormat
    let onstalled = p => AttrString("onstalled", p)->attrFormat
    let onstorage = p => AttrString("onstorage", p)->attrFormat
    let ontimeupdate = p => AttrString("ontimeupdate", p)->attrFormat
    let ontoggle = p => AttrString("ontoggle", p)->attrFormat
    let onunload = p => AttrString("onunload", p)->attrFormat
    let onvolumechange = p => AttrString("onvolumechange", p)->attrFormat
    let onwaiting = p => AttrString("onwaiting", p)->attrFormat
    let onwheel = p => AttrString("onwheel", p)->attrFormat
    let open_ = p => AttrBool("open", p)->attrFormat
    let optimum = p => AttrString("optimum", p->Js.Float.toString)->attrFormat
    let placeholder = p => AttrString("placeholder", p)->attrFormat
    let pattern = p => AttrString("pattern", p)->attrFormat
    let poster = p => AttrString("poster", p)->attrFormat
    let preload = p => {
      let toString = switch p {
      | #None => "none"
      | #Auto => "auto"
      | #Metadata => "metadata"
      }
      AttrString("preload", toString)->attrFormat
    }
    let property = p => AttrString("property", p)->attrFormat
    let readonly = p => AttrBool("readonly", p)->attrFormat
    let rel_a = (p) => {
      let toString = switch p {
      | #Author => "author"
      | #Alternate => "alternate"
      | #Bookmark => "bookmark"
      | #External => "external"
      | #Help => "help"
      | #License => "license"
      | #Next => "next"
      | #Nofollow => "nofollow"
      | #Noopener => "noopener"
      | #Noreferrer => "noreferrer"
      | #Prev => "prev"
      | #Search => "search"
      | #Tag => "tag"
      }
      AttrString("rel", toString)->attrFormat
    }
    let rel_area = rel_a
    let rel_form = p => {
      let toString = switch p {
      | #External => "external"
      | #Help => "help"
      | #License => "license"
      | #Next => "next"
      | #Nofollow => "nofollow"
      | #Noopener => "noopener"
      | #Noreferrer => "noreferrer"
      | #Prev => "prev"
      | #Search => "search"
      }
      AttrString("rel", toString)->attrFormat
    }
    let rel_link = p => {
      let toString = switch p {
      | #Alternate => "alternate"
      | #Author => "author"
      | #DnsPrefetch => "dns-prefetch"
      | #Help => "help"
      | #Icon => "icon"
      | #License => "license"
      | #Next => "next"
      | #Pingback => "pingback"
      | #Preconnect => "preconnect"
      | #Prefetch => "prefetch"
      | #Preload => "preload"
      | #Prerender => "prerender"
      | #Prev => "prev"
      | #Search => "search"
      | #Stylesheet => "stylesheet"
      }
      AttrString("rel", toString)->attrFormat
    }
    let required = p => AttrBool("required",p)->attrFormat
    let reversed = p => AttrBool("reversed",p)->attrFormat
    let rows = p => AttrInt("rows", p)->attrFormat
    let rowspan = p => AttrInt("rowspan", p)->attrFormat
    // let sandbox = p => ???
    let scope = p => AttrString("scope", p)->attrFormat
    let selected = p => AttrBool("selected",p)->attrFormat
    let shape = p => {
      let toString = switch p {
      | #Default => "default"
      | #Rect => "rect"
      | #Circle => "circle"
      | #Poly => "poly"
      }
      AttrString("shape", toString)->attrFormat
    }
    let size = p => AttrInt("size", p)->attrFormat
    let sizes = p => AttrString("sizes", p)->attrFormat
    let span = p => AttrInt("span", p)->attrFormat
    let spellcheck = p => AttrBool("spellcheck", p)->attrFormat
    let src = p => AttrString("src", p)->attrFormat
    let srcdoc = p => AttrString("srcdoc", p)->attrFormat
    let srclang = p => AttrString("srclang", p)->attrFormat
    let srcset = p => AttrString("srcset", p)->attrFormat
    let start = p => AttrInt("start", p)->attrFormat
    let step = p => AttrInt("step", p)->attrFormat
    let style = p => AttrString("style", p)->attrFormat
    let tabindex = p => AttrInt("tabindex", p)->attrFormat
    let title = p => AttrString("title", p)->attrFormat
    let type_ = p => AttrString("type", p)->attrFormat
    let target = p => {
      let toString = switch p {
      | #Blank => "_blank"
      | #Self => "_self"
      | #Parent => "_parent"
      | #Top => "_top"
      | #Framename => "framename"
      }
      AttrString("target", toString)->attrFormat
    }
    let usemap = p => AttrString("usemap", p)->attrFormat
    let value = p => AttrString("value", p)->attrFormat
    let width = p => AttrString("width", p->Js.Float.toString)->attrFormat
    let wrap = p => {
      let toString = switch p {
      | #Soft => "soft"
      | #Hard => "hard"
      }
      AttrString("wrap", toString)->attrFormat
    }
  }
}