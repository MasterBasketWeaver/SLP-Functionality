permissionset 50101 "WSB SLP Permissions2"
{
    Caption = 'SLP Functionality Permissions';
    Permissions = tabledata "WSB SLP Timekeeper" = rimd,
    table "WSB SLP Timekeeper" = x,
    report "WSB SLP Case List Summary" = x,
    report "WSB SLP Resource Time Summary" = x,
    report "WSB SLP Test Invoice" = x;
}