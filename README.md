# Google Analytics Client ID & Session Information

Use this Google Tag Manager variable template to easily access Google Analytics session details without directly interacting with Google Analytics cookies.

## How Does It Work?

This GTM variable template leverages the `readAnalyticsStorage` API to retrieve session information. This method ensures your measurement implementation won't break, even if the Google Analytics cookie format changes in the future.

## Installation

-   Open your Google Tag Manager container for editing.
    
-   Navigate to the `Workspace` page from the top menu.
    
-   Click on `Templates` in the left-hand menu.
    
-   In the `Variable templates` box, click `Search Gallery`.
    
-   Find the template named "Google Analytics Client ID & Session Information."
    
-   Click `Add to workspace` and follow the on-screen instructions.

## Usage

Create a new `User Defined Variable` and select "Google Analytics Client ID & Session Information" as the variable type. If you keep all the default settings, the variable will return a JSON object similar to this:

```
{
  "client_id": "8888888888.9999999999",
  "sessions": [
    {
      "measurement_id": "G-ABCD1DEF88",
      "session_id": "9999999999",
      "session_number": 2
    }
  ]
}
```

You'll find one client ID for each Google Analytics instance loaded on your website. However, each instance will have its own distinct session ID and session number, represented as an array within the `sessions` key.

To refine the variable data returned, you can use two filtering options:

### Which Data?

From the `Which data?` dropdown, you can select exactly what you need your variable to return: `Client ID`, `Session ID`, `Session Number`, or only the `Measurement ID`. Selecting `Client ID` will return just the client ID as a string. All other data types will be returned as an array, even if there's only a single value.

### Multiple Google Analytics Sessions

If you only need data for a specific session index or a particular measurement ID, you can use the filters provided in this section of the variable template.

### Combine Them

By combining both options, you can even retrieve a single string value. For example, select `Session ID` or `Session Number` from `Which data?` and then filter the returned data to a specific `Measurement ID` to get a single string value from the variable template.

## Support

This is an open-source project created in my free time to contribute to the community. Therefore, support is limited. While you can open tickets on the Issues tab, please be aware that response times may vary.

Feel free to share your ideas, and as always, Pull Requests are very welcome!
