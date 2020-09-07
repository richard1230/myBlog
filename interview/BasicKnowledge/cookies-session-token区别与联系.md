[TOC]


## Cookies
### Cookie 是什么
1. Cookie 是浏览器访问服务器后，服务器传给浏览器的一段数据。
2. 浏览器需要保存这段数据，不得轻易删除。
3. 此后每次浏览器访问该服务器，都必须带上这段数据。
### cookies作用
第一个作用是识别用户身份。
比如用户 A 用浏览器访问了 [http://a.com](https://link.zhihu.com/?target=http%3A//a.com)，那么 [http://a.com](https://link.zhihu.com/?target=http%3A//a.com) 的服务器就会立刻给 A 返回一段数据「uid=1」（这就是 Cookie）。当 A 再次访问 [http://a.com](https://link.zhihu.com/?target=http%3A//a.com) 的其他页面时，就会附带上「uid=1」这段数据。
同理，用户 B 用浏览器访问 [http://a.com](https://link.zhihu.com/?target=http%3A//a.com) 时，[http://a.com](https://link.zhihu.com/?target=http%3A//a.com) 发现 B 没有附带 uid 数据，就给 B 分配了一个新的 uid，为2，然后返回给 B 一段数据「uid=2」。B 之后访问 [http://a.com](https://link.zhihu.com/?target=http%3A//a.com) 的时候，就会一直带上「uid=2」这段数据。
借此，[http://a.com](https://link.zhihu.com/?target=http%3A//a.com) 的服务器就能区分 A 和 B 两个用户了。
第二个作用是记录历史。
假设 [http://a.com](https://link.zhihu.com/?target=http%3A//a.com) 是一个购物网站，当 A 在上面将商品 A1 、A2 加入购物车时，JS 可以改写 Cookie，改为「uid=1; cart=A1,A2」，表示购物车里有 A1 和 A2 两样商品了。
这样一来，当用户关闭网页，过三天再打开网页的时候，依然可以看到 A1、A2 躺在购物车里，因为浏览器并不会无缘无故地删除这个 Cookie。

### cookies的实现(重点)
服务器通过 Set-Cookie 头给客户端一串字符串(背) 
客户端每次访问相同域名的网页时，必须带上这段字符串(背) 
客户端要在一段时间内保存这个Cookie(背) 
Cookie 默认在用户关闭页面后就失效，后台代码可以任意设置 Cookie 的过期时间;
### cookies缺点
cookies里面的信息(用户名密码等)可以被人随意篡改;
## session
Cookie是存储在客户端方，Session是存储在服务端方，客户端只存储SessionId;
在上面我们了解了什么是Cookie，既然浏览器已经通过Cookie实现了有状态这一需求，那么为什么又来了一个Session呢？这里我们想象一下，如果将账户的一些信息都存入Cookie中的话，一旦信息被拦截，那么我们所有的账户信息都会丢失掉。所以就出现了Session，在一次会话中将重要信息保存在Session中，浏览器只记录一个SessionId即可;SessionId对应一次会话请求。
其实session就是存储在服务器中的一块hash表!!
现在是这样的:

### session实现
服务器的返回头中在Cookie中生成了一个SessionId;(原来cookies的套路是直接把用户名,用户密码等用户信息发送回去,现在是在服务端这边将用户信息保存在一个hash表里面,每个用户信息对应一个sessionid)
然后浏览器记住此SessionId下次访问时可以带着此Id，然后就能根据此Id找到存储在服务端的信息了.
### session什么时候过期
* 客户端：和Cookie过期一致，如果没设置，默认是关了浏览器就没了，即再打开浏览器的时候初次请求头中是没有SessionId了。
* 服务端：服务端的过期是真的过期，即服务器端的Session存储的数据结构多久不可用了，默认是30分钟。


### session其他相关知识
既然我们知道了Session是在服务端进行管理的，那么或许你们看到这有几个疑问，Session是在在哪创建的？Session是存储在什么数据结构中？接下来带领大家一起看一下Session是如何被管理的。
Session的管理是在容器中被管理的，什么是容器呢？Tomcat、Jetty等都是容器。接下来我们拿最常用的Tomcat为例来看下Tomcat是如何管理Session的。在ManageBase的createSession是用来创建Session的。
```
@Override


public Session createSession(String sessionId) {


    //首先判断Session数量是不是到了最大值，最大Session数可以通过参数设置


    if ((maxActiveSessions &gt;= 0) &amp;&amp;


            (getActiveSessions() &gt;= maxActiveSessions)) {


        rejectedSessions++;


        throw new TooManyActiveSessionsException(


                sm.getString("managerBase.createSession.ise"),


                maxActiveSessions);


    }




    // 重用或者创建一个新的Session对象，请注意在Tomcat中就是StandardSession


    // 它是HttpSession的具体实现类，而HttpSession是Servlet规范中定义的接口


    Session session = createEmptySession();






    // 初始化新Session的值


    session.setNew(true);


    session.setValid(true);


    session.setCreationTime(System.currentTimeMillis());


    // 设置Session过期时间是30分钟


    session.setMaxInactiveInterval(getContext().getSessionTimeout() * 60);


    String id = sessionId;


    if (id == null) {


        id = generateSessionId();


    }


    session.setId(id);// 这里会将Session添加到ConcurrentHashMap中


    sessionCounter++;


    


    //将创建时间添加到LinkedList中，并且把最先添加的时间移除


    //主要还是方便清理过期Session


    SessionTiming timing = new SessionTiming(session.getCreationTime(), 0);


    synchronized (sessionCreationTiming) {


        sessionCreationTiming.add(timing);


        sessionCreationTiming.poll();


    }


    return session


}
```
到此我们明白了Session是如何创建出来的，创建出来后Session会被保存到一个ConcurrentHashMap中。可以看StandardSession类。


```
protected Map<string, session> sessions = new ConcurrentHashMap&lt;&gt;();


```
> Session是存储在Tomcat的容器中，所以如果后端机器是多台的话，因此多个机器间是无法共享Session的，此时可以使用Spring提供的分布式Session的解决方案，是将Session放在了Redis中
### session和cookies基本流程总结(重点)
session,注册登录->服务端将user存入session->将sessionid存入浏览器的cookie->再次访问时根据cookie里的sessionid找到session里的user

### session的缺点
先说一下用户认证流程:
1、用户向服务器发送用户名和密码。


2、服务器验证通过后，在当前对话（session）里面保存相关数据，比如用户角色、登录时间等等。


3、服务器向用户返回一个 session_id，写入用户的 Cookie。


4、用户随后的每一次请求，都会通过 Cookie，将 session_id 传回服务器。


5、服务器收到 session_id，找到前期保存的数据，由此得知用户的身份。


这种模式的问题在于，扩展性（scaling）不好。单机当然没有问题，如果是服务器集群，或者是跨域的服务导向架构，就要求 session 数据共享，每台服务器都能够读取 session。


举例来说，A 网站和 B 网站是同一家公司的关联服务。现在要求，用户只要在其中一个网站登录，再访问另一个网站就会自动登录，请问怎么实现？


一种解决方案是 session 数据持久化，写入数据库或别的持久层。各种服务收到请求后，都向持久层请求数据。这种方案的优点是架构清晰，缺点是工程量比较大。另外，持久层万一挂了，就会单点失败。


另一种方案是服务器索性不保存 session 数据了，所有数据都保存在客户端，每次请求都发回服务器。JWT 就是这种方案的一个代表。

## Token
### token概要
Session是将需要验证的信息存储在服务端,并以SessionId和数据进行对应,sessionId由客户端存储,在请求时将SessionId也带过去,因此
实现了状态的对应;
而token是在服务端将用户信息经过Base64Url编码之后传给客户端;每次用户请求的时候都会带上这一段信息,因此服务端拿到此信息进行解密之后就知道词用户是谁了,这个方法叫做jwt(Json Web Token)
### token产生的原因
在介绍基于Token的身份验证的原理与优势之前，不妨先看看之前的认证都是怎么做的。

### 基于服务器的验证:
我们都是知道HTTP协议是无状态的，这种无状态意味着程序需要验证每一次请求，从而辨别客户端的身份。
在这之前，程序都是通过在服务端存储的登录信息来辨别请求的。这种方式一般都是通过存储Session来完成。
 随着Web，应用程序，已经移动端的兴起，这种验证的方式逐渐暴露出了问题。尤其是在可扩展性方面。
### 基于服务器的验证的一些缺点:
1. Seesion：每次认证用户发起请求时，服务器需要去创建一个记录来存储信息。当越来越多的用户发请求时，内存的开销也会不断增加。


2. 可扩展性：在服务端的内存中使用Seesion存储登录信息，伴随而来的是可扩展性问题。


3. CORS(跨域资源共享)：当我们需要让数据跨多台移动设备上使用时，跨域资源的共享会是一个让人头疼的问题。在使用Ajax抓取另一个域的资源，就可以会出现禁止请求的情况。


4. CSRF(跨站请求伪造)：用户在访问银行网站时，他们很容易受到跨站请求伪造的攻击，并且能够被利用其访问其他的网站。


在这些问题中，可扩展性是最突出的。因此我们有必要去寻求一种更有行之有效的方法。
可扩展性的解释(何为可扩展性):
Tokens能够创建与其它程序共享权限的程序。例如，能将一个随便的社交帐号和自己的大号(Fackbook或是Twitter)联系起来。当通过服务登录Twitter(我们将这个过程Buffer)时，我们可以将这些Buffer附到Twitter的数据流上(we are allowing Buffer to post to our Twitter stream)。
使用tokens时，可以提供可选的权限给第三方应用程序。当用户想让另一个应用程序访问它们的数据，我们可以通过建立自己的API，得出特殊权限的tokens。
我们已经知道session时有状态的，一般存于服务器内存或硬盘中，当服务器采用分布式或集群时，session就会面对负载均衡问题。
负载均衡多服务器的情况，不好确认当前用户是否登录，因为多服务器不共享session。这个问题也可以将session存在一个服务器中来解决，但是就不能完全达到负载均衡的效果。当今的几种[解决session负载均衡](http://blog.51cto.com/zhibeiwang/1965018)的方法。
而token是无状态的，token字符串里就保存了所有的用户信息
客户端登陆传递信息给服务端，服务端收到后把用户信息加密（token）传给客户端，客户端将token存放于localStroage(localStroage可以理解为本地的一个hash表)等容器中。客户端每次访问都传递token，服务端解密token，就知道这个用户是谁了。通过cpu加解密，服务端就不需要存储session占用存储空间，就很好的解决负载均衡多服务器的问题了。这个方法叫做[JWT(Json Web Token)](https://huanqiang.wang/2017/12/28/JWT%20%E4%BB%8B%E7%BB%8D/)
### token的优点
由上可知:
 Token相比较于Session的优点在于，当后端系统有多台时，由于是客户端访问时直接带着数据，因此无需做共享数据的操作。


token优点:
简洁：可以通过URL,POST参数或者是在HTTP头参数发送，因为数据量小，传输速度也很快
自包含：由于串包含了用户所需要的信息，避免了多次查询数据库
因为Token是以Json的形式保存在客户端的，所以JWT是跨语言的
不需要在服务端保存会话信息，特别适用于分布式微服务;
1.无状态、可扩展
在客户端存储的Tokens是无状态的，并且能够被扩展。基于这种无状态和不存储Session信息，负载负载均衡器能够将用户信息从一个服务传到其他服务器上。


如果我们将已验证的用户的信息保存在Session中，则每次请求都需要用户向已验证的服务器发送验证信息(称为Session亲和性)。用户量大时，可能会造成一些拥堵。


但是不要着急。使用tokens之后这些问题都迎刃而解，因为tokens自己hold住了用户的验证信息。
2.安全性
请求中发送token而不再是发送cookie能够防止CSRF(跨站请求伪造)。


即使在客户端使用cookie存储token，cookie也仅仅是一个存储机制而不是用于认证。不将信息存储在Session中，让我们少了对session操作。 


token是有时效的，一段时间之后用户需要重新验证。我们也不一定需要等到token自动失效，token有撤回的操作，通过token revocataion可以使一个特定的token或是一组有相同认证的token无效。
3.可扩展性
Tokens能够创建与其它程序共享权限的程序。


例如，能将一个随便的社交帐号和自己的大号(Fackbook或是Twitter)联系起来。


当通过服务登录Twitter(我们将这个过程Buffer)时，我们可以将这些Buffer附到Twitter的数据流上(we are allowing Buffer to post to our Twitter stream)。


使用tokens时，可以提供可选的权限给第三方应用程序。当用户想让另一个应用程序访问它们的数据，我们可以通过建立自己的API，得出特殊权限的tokens。


4.多平台跨域
我们提前先来谈论一下CORS(跨域资源共享,见同源策略与跨域)，对应用程序和服务进行扩展的时候，需要介入各种各种的设备和应用程序。
只要用户有一个通过了验证的token，数据和资源就能够在任何域上被请求到。


基于标准创建token的时候，你可以设定一些选项。我们在后续的文章中会进行更加详尽的描述，但是标准的用法会在JSON Web Tokens体现。


最近的程序和文档是供给JSON Web Tokens的。它支持众多的语言。这意味在未来的使用中你可以真正的转换你的认证机制。
### 基于token的验证原理

基于Token的身份验证的过程如下:
用户通过用户名和密码发送请求。
程序验证。
程序返回一个签名的token 给客户端。
客户端储存token,并且每次用于每次发送请求。
服务端验证token并返回数据。


每一次请求都需要token。token应该在HTTP的头部发送从而保证了Http请求无状态。


我们同样通过设置服务器属性Access-Control-Allow-Origin:* ，让服务器能接受到来自所有域的请求。


需要注意的是，在ACAO头部标明(designating)*时，不得带有像HTTP认证，客户端SSL证书和cookies的证书。
1. 用户登录校验，校验成功后就返回Token给客户端。
2. 客户端收到数据后保存在客户端
3. 客户端每次访问API是携带Token到服务器端。
4. 服务器端采用filter过滤器校验。校验成功则返回请求数据，校验失败则返回错误码。

当我们在程序中认证了信息并取得token之后，我们便能通过这个Token做许多的事情。


我们甚至能基于创建一个基于权限的token传给第三方应用程序，这些第三方程序能够获取到我们的数据（当然只有在我们允许的特定的token）。
## JWT相关知识(阮一峰老师有详细讲解)
[阮一峰jwt]([http://www.ruanyifeng.com/blog/2018/07/json_web_token-tutorial.html](http://www.ruanyifeng.com/blog/2018/07/json_web_token-tutorial.html))
[JWT相关]([https://huanqiang.wang/2017/12/28/JWT%20%E4%BB%8B%E7%BB%8D/](https://huanqiang.wang/2017/12/28/JWT%20%E4%BB%8B%E7%BB%8D/))
[JWT]([https://zhuanlan.zhihu.com/p/101819794](https://zhuanlan.zhihu.com/p/101819794))
## 总结(重要)

 cookie 和session的区别
1、cookie数据存放在客户的浏览器上，session数据放在服务器上。


2、cookie不是很安全，别人可以分析存放在本地的COOKIE并进行COOKIE欺骗
   考虑到安全应当使用session。


3、session会在一定时间内保存在服务器上。当访问增多，会比较占用你服务器的性能
   考虑到减轻服务器性能方面，应当使用COOKIE。


4、单个cookie保存的数据不能超过4K，很多浏览器都限制一个站点最多保存20个cookie。


5、所以个人建议：
   将登陆信息等重要信息存放为SESSION
   其他信息如果需要保留，可以放在COOKIE中


session存储于服务器，可以理解为一个状态列表，拥有一个唯一识别符号sessionId，通常存放于cookie中。服务器收到cookie后解析出sessionId，再去session列表中查找，才能找到相应session。依赖cookie
cookie类似一个令牌，装有sessionId，存储在客户端，浏览器通常会自动添加。
token也类似一个令牌，无状态，用户信息都被加密到token中，服务器收到token后解密就可知道是哪个用户。需要开发者手动添加。
jwt只是一个跨域认证的方案
### jwt的几个特点
（1）JWT 默认是不加密，但也是可以加密的。生成原始 Token 以后，可以用密钥再加密一次。


（2）JWT 不加密的情况下，不能将秘密数据写入 JWT。


（3）JWT 不仅可以用于认证，也可以用于交换信息。有效使用 JWT，可以降低服务器查询数据库的次数。


（4）JWT 的最大缺点是，由于服务器不保存 session 状态，因此无法在使用过程中废止某个 token，或者更改 token 的权限。也就是说，一旦 JWT 签发了，在到期之前就会始终有效，除非服务器部署额外的逻辑。


（5）JWT 本身包含了认证信息，一旦泄露，任何人都可以获得该令牌的所有权限。为了减少盗用，JWT 的有效期应该设置得比较短。对于一些比较重要的权限，使用时应该再次对用户进行认证。


（6）为了减少盗用，JWT 不应该使用 HTTP 协议明码传输，要使用 HTTPS 协议传输。
## 参考文献
[http://www.ruanyifeng.com/blog/2018/07/json_web_token-tutorial.html](http://www.ruanyifeng.com/blog/2018/07/json_web_token-tutorial.html)
 [https://segmentfault.com/a/1190000017831088](https://segmentfault.com/a/1190000017831088)
[https://huanqiang.wang/2017/12/28/JWT%20%E4%BB%8B%E7%BB%8D/](https://huanqiang.wang/2017/12/28/JWT%20%E4%BB%8B%E7%BB%8D/)
[https://zhuanlan.zhihu.com/p/101819794](https://zhuanlan.zhihu.com/p/101819794)
  [https://zhuanlan.zhihu.com/p/63061864](https://zhuanlan.zhihu.com/p/63061864)
[https://juejin.im/post/5d01f82cf265da1b67210869#heading-12](https://juejin.im/post/5d01f82cf265da1b67210869#heading-12) 


