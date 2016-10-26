btn <- hardware.pin1;
btn.configure(DIGITAL_IN_PULLUP, function() {
    agent.send("email", true);
});
