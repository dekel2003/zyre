(*
################################################################################
#  THIS FILE IS 100% GENERATED BY ZPROJECT; DO NOT EDIT EXCEPT EXPERIMENTALLY  #
#  Read the zproject/README.md for information about making permanent changes. #
################################################################################
*)

unit Zyre;

interface

uses
  CZMQ,
  libzyre, Winapi.Windows, Winapi.Winsock2;

// forward declarations
 type
  IZyre = interface;
  IZyreEvent = interface;

  // An open-source framework for proximity-based P2P apps
  IZyre = interface

    // Return our node UUID string, after successful initialization
    function Uuid: string;

    // Return our node name, after successful initialization. First 6
    // characters of UUID by default.
    function Name: string;

    // Set the public name of this node overriding the default. The name is
    // provide during discovery and come in each ENTER message.
    procedure SetName(const Name: string);

    // Set node header; these are provided to other nodes during discovery
    // and come in each ENTER message.
    procedure SetHeader(const Name: string; const Format: string);

    // Set verbose mode; this tells the node to log all traffic as well as
    // all major events.
    procedure SetVerbose;

    // Set UDP beacon discovery port; defaults to 5670, this call overrides
    // that so you can create independent clusters on the same network, for
    // e.g. development vs. production. Has no effect after zyre_start().
    procedure SetPort(PortNbr: Integer);

    // Set the TCP port bound by the ROUTER peer-to-peer socket (beacon mode).
    // Defaults to * (the port is randomly assigned by the system).
    // This call overrides this, to bypass some firewall issues when ports are
    // random. Has no effect after zyre_start().
    procedure SetBeaconPeerPort(PortNbr: Integer);

    // Set the peer evasiveness timeout, in milliseconds. Default is 5000.
    // This can be tuned in order to deal with expected network conditions
    // and the response time expected by the application. This is tied to
    // the beacon interval and rate of messages received.
    procedure SetEvasiveTimeout(Interval: Integer);

    // Set the peer silence timeout, in milliseconds. Default is 5000.
    // This can be tuned in order to deal with expected network conditions
    // and the response time expected by the application. This is tied to
    // the beacon interval and rate of messages received.
    // Silence is triggered one second after the timeout if peer has not
    // answered ping and has not sent any message.
    // NB: this is currently redundant with the evasiveness timeout. Both
    // affect the same timeout value.
    procedure SetSilentTimeout(Interval: Integer);

    // Set the peer expiration timeout, in milliseconds. Default is 30000.
    // This can be tuned in order to deal with expected network conditions
    // and the response time expected by the application. This is tied to
    // the beacon interval and rate of messages received.
    procedure SetExpiredTimeout(Interval: Integer);

    // Set UDP beacon discovery interval, in milliseconds. Default is instant
    // beacon exploration followed by pinging every 1,000 msecs.
    procedure SetInterval(Interval: NativeUInt);

    // Set network interface for UDP beacons. If you do not set this, CZMQ will
    // choose an interface for you. On boxes with several interfaces you should
    // specify which one you want to use, or strange things can happen.
    procedure SetInterface(const Value: string);

    // By default, Zyre binds to an ephemeral TCP port and broadcasts the local
    // host name using UDP beaconing. When you call this method, Zyre will use
    // gossip discovery instead of UDP beaconing. You MUST set-up the gossip
    // service separately using zyre_gossip_bind() and _connect(). Note that the
    // endpoint MUST be valid for both bind and connect operations. You can use
    // inproc://, ipc://, or tcp:// transports (for tcp://, use an IP address
    // that is meaningful to remote as well as local nodes). Returns 0 if
    // the bind was successful, else -1.
    function SetEndpoint(const Format: string): Integer;

    // This options enables a peer to actively contest for leadership in the
    // given group. If this option is not set the peer will still participate in
    // elections but never gets elected. This ensures that a consent for a leader
    // is reached within a group even though not every peer is contesting for
    // leadership.
    procedure SetContestInGroup(const Group: string);

    // Set an alternative endpoint value when using GOSSIP ONLY. This is useful
    // if you're advertising an endpoint behind a NAT.
    procedure SetAdvertisedEndpoint(const Value: string);

    // Apply a azcert to a Zyre node.
    procedure SetZcert(const Zcert: IZcert);

    // Specify the ZAP domain (for use with CURVE).
    procedure SetZapDomain(const Domain: string);

    // Set-up gossip discovery of other nodes. At least one node in the cluster
    // must bind to a well-known gossip endpoint, so other nodes can connect to
    // it. Note that gossip endpoints are completely distinct from Zyre node
    // endpoints, and should not overlap (they can use the same transport).
    procedure GossipBind(const Format: string);

    // Set-up gossip discovery of other nodes. A node may connect to multiple
    // other nodes, for redundancy paths. For details of the gossip network
    // design, see the CZMQ zgossip class.
    procedure GossipConnect(const Format: string);

    // Set-up gossip discovery with CURVE enabled.
    procedure GossipConnectCurve(const PublicKey: string; const Format: string);

    // Unpublish a GOSSIP node from local list, useful in removing nodes from list when they EXIT
    procedure GossipUnpublish(const Node: string);

    // Start node, after setting header values. When you start a node it
    // begins discovery and connection. Returns 0 if OK, -1 if it wasn't
    // possible to start the node.
    function Start: Integer;

    // Stop node; this signals to other peers that this node will go away.
    // This is polite; however you can also just destroy the node without
    // stopping it.
    procedure Stop;

    // Join a named group; after joining a group you can send messages to
    // the group and all Zyre nodes in that group will receive them.
    function Join(const Group: string): Integer;

    // Leave a group
    function Leave(const Group: string): Integer;

    // Receive next message from network; the message may be a control
    // message (ENTER, EXIT, JOIN, LEAVE) or data (WHISPER, SHOUT).
    // Returns zmsg_t object, or NULL if interrupted
    function Recv: IZmsg;

    // Send message to single peer, specified as a UUID string
    // Destroys message after sending
    function Whisper(const Peer: string; var MsgP: IZmsg): Integer;

    // Send message to a named group
    // Destroys message after sending
    function Shout(const Group: string; var MsgP: IZmsg): Integer;

    // Send formatted string to a single peer specified as UUID string
    function Whispers(const Peer: string; const Format: string): Integer;

    // Send formatted string to a named group
    function Shouts(const Group: string; const Format: string): Integer;

    // Return zlist of current peer ids.
    function Peers: IZlist;

    // Return zlist of current peers of this group.
    function PeersByGroup(const Name: string): IZlist;

    // Return zlist of currently joined groups.
    function OwnGroups: IZlist;

    // Return zlist of groups known through connected peers.
    function PeerGroups: IZlist;

    // Return the endpoint of a connected peer.
    // Returns empty string if peer does not exist.
    function PeerAddress(const Peer: string): string;

    // Return the value of a header of a conected peer.
    // Returns null if peer or key doesn't exits.
    function PeerHeaderValue(const Peer: string; const Name: string): string;

    // Explicitly connect to a peer
    function RequirePeer(const Uuid: string; const Endpoint: string; const PublicKey: string): Integer;

    // Return socket for talking to the Zyre node, for polling
    function Socket: IZsock;

    // Return underlying ZMQ socket for talking to the Zyre node,
    // for polling with libzmq (base ZMQ library)
    function SocketZmq: IZSock;

    // Print zyre node information to stdout
    procedure Print;
  end;

  // Parsing Zyre messages
  IZyreEvent = interface

    // Returns event type, as printable uppercase string. Choices are:
    // "ENTER", "EXIT", "JOIN", "LEAVE", "EVASIVE", "WHISPER" and "SHOUT"
    // and for the local node: "STOP"
    function &Type: string;

    // Return the sending peer's uuid as a string
    function PeerUuid: string;

    // Return the sending peer's public name as a string
    function PeerName: string;

    // Return the sending peer's ipaddress as a string
    function PeerAddr: string;

    // Returns the event headers, or NULL if there are none
    function Headers: IZhash;

    // Returns value of a header from the message headers
    // obtained by ENTER. Return NULL if no value was found.
    function Header(const Name: string): string;

    // Returns the group name that a SHOUT event was sent to
    function Group: string;

    // Returns the incoming message payload; the caller can modify the
    // message but does not own it and should not destroy it.
    function Msg: IZmsg;

    // Returns the incoming message payload, and pass ownership to the
    // caller. The caller must destroy the message when finished with it.
    // After called on the given event, further calls will return NULL.
    function GetMsg: IZmsg;

    // Print event to zsys log
    procedure Print;
  end;

  // An open-source framework for proximity-based P2P apps
  TZyre = class(TInterfacedObject, IZyre)
  public
    FOwned: Boolean;
    FHandle: PZyre;
    constructor Create(handle: PZyre; owned: Boolean);
  public

    // Constructor, creates a new Zyre node. Note that until you start the
    // node it is silent and invisible to other nodes on the network.
    // The node name is provided to other nodes during discovery. If you
    // specify NULL, Zyre generates a randomized node name from the UUID.
    constructor New(const Name: string);

    // Destructor, destroys a Zyre node. When you destroy a node, any
    // messages it is sending or receiving will be discarded.
    destructor Destroy; override;

    // Return the Zyre version for run-time API detection; returns
    // major * 10000 + minor * 100 + patch, as a single integer.
    class function Version: UInt64;

    // Self test of this class.
    class procedure Test(Verbose: Boolean);

    class function Wrap(handle: PZyre; owned: Boolean): IZyre;
    class function UnWrap(const Value: IZyre): PZyre;
  protected

    // Return our node UUID string, after successful initialization
    function Uuid: string;

    // Return our node name, after successful initialization. First 6
    // characters of UUID by default.
    function Name: string;

    // Set the public name of this node overriding the default. The name is
    // provide during discovery and come in each ENTER message.
    procedure SetName(const Name: string);

    // Set node header; these are provided to other nodes during discovery
    // and come in each ENTER message.
    procedure SetHeader(const Name: string; const Format: string);

    // Set verbose mode; this tells the node to log all traffic as well as
    // all major events.
    procedure SetVerbose;

    // Set UDP beacon discovery port; defaults to 5670, this call overrides
    // that so you can create independent clusters on the same network, for
    // e.g. development vs. production. Has no effect after zyre_start().
    procedure SetPort(PortNbr: Integer);

    // Set the TCP port bound by the ROUTER peer-to-peer socket (beacon mode).
    // Defaults to * (the port is randomly assigned by the system).
    // This call overrides this, to bypass some firewall issues when ports are
    // random. Has no effect after zyre_start().
    procedure SetBeaconPeerPort(PortNbr: Integer);

    // Set the peer evasiveness timeout, in milliseconds. Default is 5000.
    // This can be tuned in order to deal with expected network conditions
    // and the response time expected by the application. This is tied to
    // the beacon interval and rate of messages received.
    procedure SetEvasiveTimeout(Interval: Integer);

    // Set the peer silence timeout, in milliseconds. Default is 5000.
    // This can be tuned in order to deal with expected network conditions
    // and the response time expected by the application. This is tied to
    // the beacon interval and rate of messages received.
    // Silence is triggered one second after the timeout if peer has not
    // answered ping and has not sent any message.
    // NB: this is currently redundant with the evasiveness timeout. Both
    // affect the same timeout value.
    procedure SetSilentTimeout(Interval: Integer);

    // Set the peer expiration timeout, in milliseconds. Default is 30000.
    // This can be tuned in order to deal with expected network conditions
    // and the response time expected by the application. This is tied to
    // the beacon interval and rate of messages received.
    procedure SetExpiredTimeout(Interval: Integer);

    // Set UDP beacon discovery interval, in milliseconds. Default is instant
    // beacon exploration followed by pinging every 1,000 msecs.
    procedure SetInterval(Interval: NativeUInt);

    // Set network interface for UDP beacons. If you do not set this, CZMQ will
    // choose an interface for you. On boxes with several interfaces you should
    // specify which one you want to use, or strange things can happen.
    procedure SetInterface(const Value: string);

    // By default, Zyre binds to an ephemeral TCP port and broadcasts the local
    // host name using UDP beaconing. When you call this method, Zyre will use
    // gossip discovery instead of UDP beaconing. You MUST set-up the gossip
    // service separately using zyre_gossip_bind() and _connect(). Note that the
    // endpoint MUST be valid for both bind and connect operations. You can use
    // inproc://, ipc://, or tcp:// transports (for tcp://, use an IP address
    // that is meaningful to remote as well as local nodes). Returns 0 if
    // the bind was successful, else -1.
    function SetEndpoint(const Format: string): Integer;

    // This options enables a peer to actively contest for leadership in the
    // given group. If this option is not set the peer will still participate in
    // elections but never gets elected. This ensures that a consent for a leader
    // is reached within a group even though not every peer is contesting for
    // leadership.
    procedure SetContestInGroup(const Group: string);

    // Set an alternative endpoint value when using GOSSIP ONLY. This is useful
    // if you're advertising an endpoint behind a NAT.
    procedure SetAdvertisedEndpoint(const Value: string);

    // Apply a azcert to a Zyre node.
    procedure SetZcert(const Zcert: IZcert);

    // Specify the ZAP domain (for use with CURVE).
    procedure SetZapDomain(const Domain: string);

    // Set-up gossip discovery of other nodes. At least one node in the cluster
    // must bind to a well-known gossip endpoint, so other nodes can connect to
    // it. Note that gossip endpoints are completely distinct from Zyre node
    // endpoints, and should not overlap (they can use the same transport).
    procedure GossipBind(const Format: string);

    // Set-up gossip discovery of other nodes. A node may connect to multiple
    // other nodes, for redundancy paths. For details of the gossip network
    // design, see the CZMQ zgossip class.
    procedure GossipConnect(const Format: string);

    // Set-up gossip discovery with CURVE enabled.
    procedure GossipConnectCurve(const PublicKey: string; const Format: string);

    // Unpublish a GOSSIP node from local list, useful in removing nodes from list when they EXIT
    procedure GossipUnpublish(const Node: string);

    // Start node, after setting header values. When you start a node it
    // begins discovery and connection. Returns 0 if OK, -1 if it wasn't
    // possible to start the node.
    function Start: Integer;

    // Stop node; this signals to other peers that this node will go away.
    // This is polite; however you can also just destroy the node without
    // stopping it.
    procedure Stop;

    // Join a named group; after joining a group you can send messages to
    // the group and all Zyre nodes in that group will receive them.
    function Join(const Group: string): Integer;

    // Leave a group
    function Leave(const Group: string): Integer;

    // Receive next message from network; the message may be a control
    // message (ENTER, EXIT, JOIN, LEAVE) or data (WHISPER, SHOUT).
    // Returns zmsg_t object, or NULL if interrupted
    function Recv: IZmsg;

    // Send message to single peer, specified as a UUID string
    // Destroys message after sending
    function Whisper(const Peer: string; var MsgP: IZmsg): Integer;

    // Send message to a named group
    // Destroys message after sending
    function Shout(const Group: string; var MsgP: IZmsg): Integer;

    // Send formatted string to a single peer specified as UUID string
    function Whispers(const Peer: string; const Format: string): Integer;

    // Send formatted string to a named group
    function Shouts(const Group: string; const Format: string): Integer;

    // Return zlist of current peer ids.
    function Peers: IZlist;

    // Return zlist of current peers of this group.
    function PeersByGroup(const Name: string): IZlist;

    // Return zlist of currently joined groups.
    function OwnGroups: IZlist;

    // Return zlist of groups known through connected peers.
    function PeerGroups: IZlist;

    // Return the endpoint of a connected peer.
    // Returns empty string if peer does not exist.
    function PeerAddress(const Peer: string): string;

    // Return the value of a header of a conected peer.
    // Returns null if peer or key doesn't exits.
    function PeerHeaderValue(const Peer: string; const Name: string): string;

    // Explicitly connect to a peer
    function RequirePeer(const Uuid: string; const Endpoint: string; const PublicKey: string): Integer;

    // Return socket for talking to the Zyre node, for polling
    function Socket: IZsock;

    // Return underlying ZMQ socket for talking to the Zyre node,
    // for polling with libzmq (base ZMQ library)
    function SocketZmq: IZSock;

    // Print zyre node information to stdout
    procedure Print;
  end;

  // Parsing Zyre messages
  TZyreEvent = class(TInterfacedObject, IZyreEvent)
  public
    FOwned: Boolean;
    FHandle: PZyreEvent;
    constructor Create(handle: PZyreEvent; owned: Boolean);
  public

    // Constructor: receive an event from the zyre node, wraps zyre_recv.
    // The event may be a control message (ENTER, EXIT, JOIN, LEAVE) or
    // data (WHISPER, SHOUT).
    constructor New(const Node: IZyre);

    // Destructor; destroys an event instance
    destructor Destroy; override;

    // Self test of this class.
    class procedure Test(Verbose: Boolean);

    class function Wrap(handle: PZyreEvent; owned: Boolean): IZyreEvent;
    class function UnWrap(const Value: IZyreEvent): PZyreEvent;
  protected

    // Returns event type, as printable uppercase string. Choices are:
    // "ENTER", "EXIT", "JOIN", "LEAVE", "EVASIVE", "WHISPER" and "SHOUT"
    // and for the local node: "STOP"
    function &Type: string;

    // Return the sending peer's uuid as a string
    function PeerUuid: string;

    // Return the sending peer's public name as a string
    function PeerName: string;

    // Return the sending peer's ipaddress as a string
    function PeerAddr: string;

    // Returns the event headers, or NULL if there are none
    function Headers: IZhash;

    // Returns value of a header from the message headers
    // obtained by ENTER. Return NULL if no value was found.
    function Header(const Name: string): string;

    // Returns the group name that a SHOUT event was sent to
    function Group: string;

    // Returns the incoming message payload; the caller can modify the
    // message but does not own it and should not destroy it.
    function Msg: IZmsg;

    // Returns the incoming message payload, and pass ownership to the
    // caller. The caller must destroy the message when finished with it.
    // After called on the given event, further calls will return NULL.
    function GetMsg: IZmsg;

    // Print event to zsys log
    procedure Print;
  end;


implementation

uses
  System.SysUtils;


 (* TZyre *)

  constructor TZyre.New(const Name: string);
  var
    __Name__: UTF8String;
  begin
    __Name__ := UTF8String(Name);
    Create(zyre_new(PAnsiChar(__Name__)), True);
  end;

  constructor TZyre.Create(handle: PZyre; owned: Boolean);
  begin
    FHandle := handle;
    FOwned := owned;
  end;

  class function TZyre.Wrap(handle: PZyre; owned: Boolean): IZyre;
  begin
    if handle <> nil then Result := TZyre.Create(handle, owned) else Result := nil;
  end;

  class function TZyre.UnWrap(const value: IZyre): PZyre;
  begin
    if value <> nil then Result := TZyre(value).FHandle else Result := nil;
  end;

  destructor TZyre.Destroy;
  begin
    if FOwned and (FHandle <> nil) then
      zyre_destroy(FHandle);
  end;

  class function TZyre.Version: UInt64;
  begin
    Result := zyre_version;
  end;

  class procedure TZyre.Test(Verbose: Boolean);
  begin
    zyre_test(Verbose);
  end;

  function TZyre.Uuid: string;
  begin
    Result := string(UTF8String(zyre_uuid(FHandle)));
  end;

  function TZyre.Name: string;
  begin
    Result := string(UTF8String(zyre_name(FHandle)));
  end;

  procedure TZyre.SetName(const Name: string);
  var
    __Name__: UTF8String;
  begin
    __Name__ := UTF8String(Name);
    zyre_set_name(FHandle, PAnsiChar(__Name__));
  end;

  procedure TZyre.SetHeader(const Name: string; const Format: string);
  var
    __Name__: UTF8String;
    __Format__: UTF8String;
  begin
    __Name__ := UTF8String(Name);
    __Format__ := UTF8String(Format);
    zyre_set_header(FHandle, PAnsiChar(__Name__), PAnsiChar(__Format__));
  end;

  procedure TZyre.SetVerbose;
  begin
    zyre_set_verbose(FHandle);
  end;

  procedure TZyre.SetPort(PortNbr: Integer);
  begin
    zyre_set_port(FHandle, PortNbr);
  end;

  procedure TZyre.SetBeaconPeerPort(PortNbr: Integer);
  begin
    zyre_set_beacon_peer_port(FHandle, PortNbr);
  end;

  procedure TZyre.SetEvasiveTimeout(Interval: Integer);
  begin
    zyre_set_evasive_timeout(FHandle, Interval);
  end;

  procedure TZyre.SetSilentTimeout(Interval: Integer);
  begin
    zyre_set_silent_timeout(FHandle, Interval);
  end;

  procedure TZyre.SetExpiredTimeout(Interval: Integer);
  begin
    zyre_set_expired_timeout(FHandle, Interval);
  end;

  procedure TZyre.SetInterval(Interval: NativeUInt);
  begin
    zyre_set_interval(FHandle, Interval);
  end;

  procedure TZyre.SetInterface(const Value: string);
  var
    __Value__: UTF8String;
  begin
    __Value__ := UTF8String(Value);
    zyre_set_interface(FHandle, PAnsiChar(__Value__));
  end;

  function TZyre.SetEndpoint(const Format: string): Integer;
  var
    __Format__: UTF8String;
  begin
    __Format__ := UTF8String(Format);
    Result := zyre_set_endpoint(FHandle, PAnsiChar(__Format__));
  end;

  procedure TZyre.SetContestInGroup(const Group: string);
  var
    __Group__: UTF8String;
  begin
    __Group__ := UTF8String(Group);
    zyre_set_contest_in_group(FHandle, PAnsiChar(__Group__));
  end;

  procedure TZyre.SetAdvertisedEndpoint(const Value: string);
  var
    __Value__: UTF8String;
  begin
    __Value__ := UTF8String(Value);
    zyre_set_advertised_endpoint(FHandle, PAnsiChar(__Value__));
  end;

  procedure TZyre.SetZcert(const Zcert: IZcert);
  begin
    zyre_set_zcert(FHandle, TZcert.UnWrap(Zcert));
  end;

  procedure TZyre.SetZapDomain(const Domain: string);
  var
    __Domain__: UTF8String;
  begin
    __Domain__ := UTF8String(Domain);
    zyre_set_zap_domain(FHandle, PAnsiChar(__Domain__));
  end;

  procedure TZyre.GossipBind(const Format: string);
  var
    __Format__: UTF8String;
  begin
    __Format__ := UTF8String(Format);
    zyre_gossip_bind(FHandle, PAnsiChar(__Format__));
  end;

  procedure TZyre.GossipConnect(const Format: string);
  var
    __Format__: UTF8String;
  begin
    __Format__ := UTF8String(Format);
    zyre_gossip_connect(FHandle, PAnsiChar(__Format__));
  end;

  procedure TZyre.GossipConnectCurve(const PublicKey: string; const Format: string);
  var
    __PublicKey__: UTF8String;
    __Format__: UTF8String;
  begin
    __PublicKey__ := UTF8String(PublicKey);
    __Format__ := UTF8String(Format);
    zyre_gossip_connect_curve(FHandle, PAnsiChar(__PublicKey__), PAnsiChar(__Format__));
  end;

  procedure TZyre.GossipUnpublish(const Node: string);
  var
    __Node__: UTF8String;
  begin
    __Node__ := UTF8String(Node);
    zyre_gossip_unpublish(FHandle, PAnsiChar(__Node__));
  end;

  function TZyre.Start: Integer;
  begin
    Result := zyre_start(FHandle);
  end;

  procedure TZyre.Stop;
  begin
    zyre_stop(FHandle);
  end;

  function TZyre.Join(const Group: string): Integer;
  var
    __Group__: UTF8String;
  begin
    __Group__ := UTF8String(Group);
    Result := zyre_join(FHandle, PAnsiChar(__Group__));
  end;

  function TZyre.Leave(const Group: string): Integer;
  var
    __Group__: UTF8String;
  begin
    __Group__ := UTF8String(Group);
    Result := zyre_leave(FHandle, PAnsiChar(__Group__));
  end;

  function TZyre.Recv: IZmsg;
  begin
    Result := TZmsg.Wrap(zyre_recv(FHandle), true);
  end;

  function TZyre.Whisper(const Peer: string; var MsgP: IZmsg): Integer;
  var
    __Peer__: UTF8String;
  begin
    __Peer__ := UTF8String(Peer);
    Result := zyre_whisper(FHandle, PAnsiChar(__Peer__), TZmsg(MsgP).FHandle);
    if TZmsg(MsgP).FHandle = nil then
      MsgP := nil;
  end;

  function TZyre.Shout(const Group: string; var MsgP: IZmsg): Integer;
  var
    __Group__: UTF8String;
  begin
    __Group__ := UTF8String(Group);
    Result := zyre_shout(FHandle, PAnsiChar(__Group__), TZmsg(MsgP).FHandle);
    if TZmsg(MsgP).FHandle = nil then
      MsgP := nil;
  end;

  function TZyre.Whispers(const Peer: string; const Format: string): Integer;
  var
    __Peer__: UTF8String;
    __Format__: UTF8String;
  begin
    __Peer__ := UTF8String(Peer);
    __Format__ := UTF8String(Format);
    Result := zyre_whispers(FHandle, PAnsiChar(__Peer__), PAnsiChar(__Format__));
  end;

  function TZyre.Shouts(const Group: string; const Format: string): Integer;
  var
    __Group__: UTF8String;
    __Format__: UTF8String;
  begin
    __Group__ := UTF8String(Group);
    __Format__ := UTF8String(Format);
    Result := zyre_shouts(FHandle, PAnsiChar(__Group__), PAnsiChar(__Format__));
  end;

  function TZyre.Peers: IZlist;
  begin
    Result := TZlist.Wrap(zyre_peers(FHandle), true);
  end;

  function TZyre.PeersByGroup(const Name: string): IZlist;
  var
    __Name__: UTF8String;
  begin
    __Name__ := UTF8String(Name);
    Result := TZlist.Wrap(zyre_peers_by_group(FHandle, PAnsiChar(__Name__)), true);
  end;

  function TZyre.OwnGroups: IZlist;
  begin
    Result := TZlist.Wrap(zyre_own_groups(FHandle), true);
  end;

  function TZyre.PeerGroups: IZlist;
  begin
    Result := TZlist.Wrap(zyre_peer_groups(FHandle), true);
  end;

  function TZyre.PeerAddress(const Peer: string): string;
  var
    __Peer__: UTF8String;
  begin
    __Peer__ := UTF8String(Peer);
    Result := ZFreeString(zyre_peer_address(FHandle, PAnsiChar(__Peer__)));
  end;

  function TZyre.PeerHeaderValue(const Peer: string; const Name: string): string;
  var
    __Peer__: UTF8String;
    __Name__: UTF8String;
  begin
    __Peer__ := UTF8String(Peer);
    __Name__ := UTF8String(Name);
    Result := ZFreeString(zyre_peer_header_value(FHandle, PAnsiChar(__Peer__), PAnsiChar(__Name__)));
  end;

  function TZyre.RequirePeer(const Uuid: string; const Endpoint: string; const PublicKey: string): Integer;
  var
    __Uuid__: UTF8String;
    __Endpoint__: UTF8String;
    __PublicKey__: UTF8String;
  begin
    __Uuid__ := UTF8String(Uuid);
    __Endpoint__ := UTF8String(Endpoint);
    __PublicKey__ := UTF8String(PublicKey);
    Result := zyre_require_peer(FHandle, PAnsiChar(__Uuid__), PAnsiChar(__Endpoint__), PAnsiChar(__PublicKey__));
  end;

  function TZyre.Socket: IZsock;
  begin
    Result := TZsock.Wrap(zyre_socket(FHandle), false);
  end;

  function TZyre.SocketZmq: IZSock;
  begin
    Result := TZsock.Wrap(zyre_socket_zmq(FHandle), false);
  end;

  procedure TZyre.Print;
  begin
    zyre_print(FHandle);
  end;

 (* TZyreEvent *)

  constructor TZyreEvent.New(const Node: IZyre);
  begin
    Create(zyre_event_new(TZyre.UnWrap(Node)), True);
  end;

  constructor TZyreEvent.Create(handle: PZyreEvent; owned: Boolean);
  begin
    FHandle := handle;
    FOwned := owned;
  end;

  class function TZyreEvent.Wrap(handle: PZyreEvent; owned: Boolean): IZyreEvent;
  begin
    if handle <> nil then Result := TZyreEvent.Create(handle, owned) else Result := nil;
  end;

  class function TZyreEvent.UnWrap(const value: IZyreEvent): PZyreEvent;
  begin
    if value <> nil then Result := TZyreEvent(value).FHandle else Result := nil;
  end;

  destructor TZyreEvent.Destroy;
  begin
    if FOwned and (FHandle <> nil) then
      zyre_event_destroy(FHandle);
  end;

  class procedure TZyreEvent.Test(Verbose: Boolean);
  begin
    zyre_event_test(Verbose);
  end;

  function TZyreEvent.&Type: string;
  begin
    Result := string(UTF8String(zyre_event_type(FHandle)));
  end;

  function TZyreEvent.PeerUuid: string;
  begin
    Result := string(UTF8String(zyre_event_peer_uuid(FHandle)));
  end;

  function TZyreEvent.PeerName: string;
  begin
    Result := string(UTF8String(zyre_event_peer_name(FHandle)));
  end;

  function TZyreEvent.PeerAddr: string;
  begin
    Result := string(UTF8String(zyre_event_peer_addr(FHandle)));
  end;

  function TZyreEvent.Headers: IZhash;
  begin
    Result := TZhash.Wrap(zyre_event_headers(FHandle), false);
  end;

  function TZyreEvent.Header(const Name: string): string;
  var
    __Name__: UTF8String;
  begin
    __Name__ := UTF8String(Name);
    Result := string(UTF8String(zyre_event_header(FHandle, PAnsiChar(__Name__))));
  end;

  function TZyreEvent.Group: string;
  begin
    Result := string(UTF8String(zyre_event_group(FHandle)));
  end;

  function TZyreEvent.Msg: IZmsg;
  begin
    Result := TZmsg.Wrap(zyre_event_msg(FHandle), false);
  end;

  function TZyreEvent.GetMsg: IZmsg;
  begin
    Result := TZmsg.Wrap(zyre_event_get_msg(FHandle), true);
  end;

  procedure TZyreEvent.Print;
  begin
    zyre_event_print(FHandle);
  end;
end.
